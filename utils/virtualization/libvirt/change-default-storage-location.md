Changing the default storage location for libvirt involves modifying the storage pool configuration. Here's a step-by-step guide to change the default storage location from /var/lib/libvirt/images to another location:

Backup Configuration: Before making any changes, it's a good idea to backup the current configuration.


```sudo cp /etc/libvirt/storage/default.xml /etc/libvirt/storage/default.xml.backup```
Stop libvirt Service: Before making changes, stop the libvirt service.


```sudo systemctl stop libvirtd```
Create the New Directory: Let's say you want to change the default location to /new/path/to/images. Create this directory and set the appropriate permissions:

```
sudo mkdir -p /new/path/to/images
sudo chown -R libvirt-qemu:kvm /new/path/to/images
```
Edit the Storage Pool Configuration:

Open the default storage pool configuration:


```sudo nano /etc/libvirt/storage/default.xml```

Find the <path> element and change its value to the new path:


<path>/new/path/to/images</path>
Save and close the file.

Refresh the Storage Pool:

Start the libvirt service:


```sudo systemctl start libvirtd```

Refresh the default storage pool:


```sudo virsh pool-refresh default```

Verify the Change: To ensure that the changes have taken effect, list the storage pools and their details:


```sudo virsh pool-list --details```

You should see the new path in the output.

Migrate Existing Images (Optional): If you have existing VM images in the old path and want to move them to the new location, you can do so:


```sudo mv /var/lib/libvirt/images/* /new/path/to/images/```

After moving the images, you might need to update the paths in the VM configurations to point to the new location.

Update SELinux Context (If SELinux is Enforced): If you're running a system with SELinux in enforcing mode, you'll need to update the security context for the new directory:

```
sudo semanage fcontext -a -t virt_image_t "/new/path/to/images(/.*)?"
sudo restorecon -R /new/path/to/images
```

That's it! You've successfully changed the default storage location for libvirt. Always remember to backup configurations before making changes, and test the changes in a non-production environment first if possible.