# Commands to build and test NeloOS locally.
# Run `make help` for the list.

IMAGE_NAME     ?= neloos
IMAGE          ?= localhost/$(IMAGE_NAME)
TAG            ?= latest
FEDORA_VERSION ?= 45
OUTPUT         ?= output
BIB_IMAGE      ?= quay.io/centos-bootc/bootc-image-builder:latest
OVMF_DIR       ?= /usr/share/edk2/ovmf
VM_RAM         ?= 6G
VM_CPUS        ?= 4

BUILD_ARGS = --pull=newer --build-arg FEDORA_VERSION=$(FEDORA_VERSION) -t $(IMAGE):$(TAG) .

BIB_RUN = sudo podman run --rm -it --privileged --pull=newer \
	--security-opt label=type:unconfined_t \
	-v ./$(OUTPUT):/output \
	-v /var/lib/containers/storage:/var/lib/containers/storage

QEMU = qemu-system-x86_64 -enable-kvm -machine q35 -cpu host \
	-smp $(VM_CPUS) -m $(VM_RAM) \
	-drive if=pflash,format=raw,readonly=on,file=$(OVMF_DIR)/OVMF_CODE.fd \
	-drive if=pflash,format=raw,file=$(OUTPUT)/OVMF_VARS.fd \
	-device virtio-vga -display gtk \
	-nic user,model=virtio-net-pci \
	-usb -device usb-tablet

.PHONY: help build build-root qcow2 iso run-vm run-iso shell clean

help: ## Show this list of commands
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-12s %s\n", $$1, $$2}'

build: ## Build the image (no sudo needed), to check the Containerfile
	podman build $(BUILD_ARGS)

build-root: build ## Copy the built image into root's storage (bootc-image-builder only reads that)
	podman save $(IMAGE):$(TAG) | sudo podman load
	sudo podman image prune -f

shell: ## Open a shell inside the built image to inspect files
	podman run --rm -it $(IMAGE):$(TAG) /bin/bash

qcow2: build-root ## Create a VM disk with NeloOS preinstalled (fastest way to test)
	mkdir -p $(OUTPUT)
	$(BIB_RUN) -v ./disk_config/disk.toml:/config.toml:ro \
		$(BIB_IMAGE) --type qcow2 --rootfs btrfs $(IMAGE):$(TAG)
	sudo chown -R $$(id -u):$$(id -g) $(OUTPUT)

iso: build-root ## Create the installer ISO (output/bootiso/install.iso)
	mkdir -p $(OUTPUT)
	$(BIB_RUN) -v ./disk_config/iso.toml:/config.toml:ro \
		$(BIB_IMAGE) --type anaconda-iso --rootfs btrfs $(IMAGE):$(TAG)
	sudo chown -R $$(id -u):$$(id -g) $(OUTPUT)

$(OUTPUT)/OVMF_VARS.fd:
	mkdir -p $(OUTPUT)
	cp $(OVMF_DIR)/OVMF_VARS.fd $@

run-vm: $(OUTPUT)/OVMF_VARS.fd ## Boot the VM from the qcow2 disk (login: nelo / nelo)
	$(QEMU) -drive file=$(OUTPUT)/qcow2/disk.qcow2,if=virtio

run-iso: $(OUTPUT)/OVMF_VARS.fd ## Test-install NeloOS from the ISO onto an empty 64GB virtual disk
	test -f $(OUTPUT)/install-test.qcow2 || qemu-img create -f qcow2 $(OUTPUT)/install-test.qcow2 64G
	$(QEMU) -drive file=$(OUTPUT)/install-test.qcow2,if=virtio \
		-cdrom $(OUTPUT)/bootiso/install.iso -boot once=d

clean: ## Delete the output directory (ISO, qcow2)
	sudo rm -rf $(OUTPUT)
