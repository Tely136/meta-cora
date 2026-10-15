# Reader completion interrupts through UIO

## What changes

The device-tree recipe adds `cora-mcs-reader-uio.dtsi` only for
`MACHINE=cora-mcs-generated`, the machine selected by `amd-edf-tools.sh`.
The existing common include and photon-bin reserved memory are unchanged.

The new include:

- Changes only `MCS_stream_reader_0` to `compatible = "generic-uio"`.
- Names the UIO device `stream-reader` so software need not assume `/dev/uio0`.
- Inherits the generated register window (0x40030000, 64 KiB), clock, and
  `interrupts = <0 30 4>`: reader on IRQ_F2P[1], active-high level-sensitive.
- Sets `/chosen/bootargs` to `uio_pdrv_genirq.of_id=generic-uio`. The generated
  Linux DTS previously had no bootargs. The existing EDF boot script reads
  this property and appends its root filesystem arguments. No boot script is
  patched. Preserve this parameter if more boot arguments are added later.

GPIO remains on its own driver and IRQ_F2P[0]. The kernel was already checked
on the board: CONFIG_UIO=y and CONFIG_UIO_PDRV_GENIRQ=y, so no kernel fragment
or root filesystem change is needed for this step.

## Build and deploy

Use your existing helper, from WSL:

```sh
bash /home/tely1/DAQ-linux-sw/scripts/amd-edf-tools.sh --bootbin
```

This regenerates the machine configuration and builds `xilinx-bootbin`. The
customization survives regeneration because it is in the recipe include.
Deploy the resulting BOOT.BIN using your established boot-partition workflow,
then reboot. Rebuilding the common Linux disk image is not required solely
for these device-tree changes. The helper's --deploy only copies to /tmp;
it does not install BOOT.BIN into the active boot partition.

## Verify on the board after reboot

```sh
cat /proc/cmdline
for device in /sys/class/uio/uio*; do
    test -e "$device/name" || continue
    printf '%s: ' "$device"
    cat "$device/name"
done
```

Expect the command line to contain the UIO parameter and one UIO device named
`stream-reader`. Keep the existing root=... ro rootwait arguments.

## Application work still required

This layer configuration makes Linux expose the device; it does not enable
HLS interrupts or change the acquisition application. The application must:

1. Identify/open the named UIO device and map its control registers (map 0).
2. Clear stale HLS interrupt status using the generated register semantics.
3. Enable HLS ap_done interrupts and the global interrupt enable.
4. Enable UIO IRQ delivery, start the reader, then start the trigger source.
5. Wait with poll/read (use a timeout), then check and acknowledge HLS status.
6. Write a 32-bit value of 1 to the UIO fd to re-enable IRQ delivery when ready.

UIO masks delivery after an interrupt. Clearing the HLS status register and
re-enabling UIO are separate actions. One UIO notification is not a count of
laser shots. The reader's ap_done represents one entire accumulation.
Result-memory coherency and preventing buffer overwrite remain application
responsibilities; UIO does not provide DMA-buffer ownership or cache handling.
