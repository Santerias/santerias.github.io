#!/bin/bash

# Remove old files
rm -f ./Packages ./Packages.bz2 ./Packages.gz ./Packages.zst ./Release

# Create a controls directory to store extracted control files
mkdir -p controls

# Extract control files from .deb packages
for deb in debs/*.deb; do
    mkdir -p tmp
    dpkg-deb -e "$deb" tmp
    control_file="controls/$(basename "$deb" .deb).control"
    cp tmp/control "$control_file"
    rm -rf tmp
done

# Generate Packages file and compressions
dpkg-scanpackages -m debs > Packages
bzip2 -k Packages
gzip -k Packages
zstd -19 Packages

# Copy base release file
cp Base Release

# Calculate file sizes and checksums
packages_size=$(ls -l Packages | awk '{print $5,$9}')
packages_md5=$(md5sum Packages | awk '{print $1}')
packages_sha256=$(sha256sum Packages | awk '{print $1}')
packagesbz2_size=$(ls -l Packages.bz2 | awk '{print $5,$9}')
packagesbz2_md5=$(md5sum Packages.bz2 | awk '{print $1}')
packagesbz2_sha256=$(sha256sum Packages.bz2 | awk '{print $1}')
packagesgz_size=$(ls -l Packages.gz | awk '{print $5,$9}')
packagesgz_md5=$(md5sum Packages.gz | awk '{print $1}')
packagesgz_sha256=$(sha256sum Packages.gz | awk '{print $1}')
packageszst_size=$(ls -l Packages.zst | awk '{print $5,$9}')
packageszst_md5=$(md5sum Packages.zst | awk '{print $1}')
packageszst_sha256=$(sha256sum Packages.zst | awk '{print $1}')

# Update Release file with MD5 and SHA256 checksums
echo "MD5Sum:" >> Release
echo " $packages_md5 $packages_size" >> Release
echo " $packagesbz2_md5 $packagesbz2_size" >> Release
echo " $packagesgz_md5 $packagesgz_size" >> Release
echo " $packageszst_md5 $packageszst_size" >> Release
echo "SHA256:" >> Release
echo " $packages_sha256 $packages_size" >> Release
echo " $packagesbz2_sha256 $packagesbz2_size" >> Release
echo " $packagesgz_sha256 $packagesgz_size" >> Release
echo " $packageszst_sha256 $packageszst_size" >> Release

echo "Done"