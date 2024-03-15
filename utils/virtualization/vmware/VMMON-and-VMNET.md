# VMMON and VMNET installation

1. https://github.com/mkubecek/vmware-host-modules
2. Download host modules
![picture 1](../../../assets/75f427b960e7b6eef2149b880d7d0844be8fe2bcd26bb03519f984bff68ff1a1.png)  
3. ```unzip file && cd file```
4. ```tar -cf vmmon.tar vmmon-only && tar -cf vmnet.tar vmnet-only```
5. ```sudo cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/```
6. ```sudo vmware-modconfig --console --install-all```

