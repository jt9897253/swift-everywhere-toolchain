require_relative "../Common/Builder.rb"

class XMLBuilder < Builder

   def initialize(arch = Arch.default)
      super(Lib.xml, arch)
      @ndk = NDK.new()
   end

   def prepare
      # Not used at the moment.
   end

   def executeConfigure
      clean()
      # Arguments took from `swift/swift-corelibs-foundation/build-android`
      archFlags = "-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
      ldFlags = "-march=armv7-a -Wl,--fix-cortex-a8"
      cmd = ["cd #{@sources} &&"]
      cmd << "CC=#{@ndk.toolchain}/bin/armv7a-linux-androideabi#{@ndk.api}-clang"
      cmd << "CXX=#{@ndk.toolchain}/bin/armv7a-linux-androideabi#{@ndk.api}-clang++"
      cmd << "AR=#{@ndk.toolchain}/bin/arm-linux-androideabi-ar"
      cmd << "AS=#{@ndk.toolchain}/bin/arm-linux-androideabi-as"
      cmd << "LD=#{@ndk.toolchain}/bin/arm-linux-androideabi-ld"
      cmd << "RANLIB=#{@ndk.toolchain}/bin/arm-linux-androideabi-ranlib"
      cmd << "NM=#{@ndk.toolchain}/bin/arm-linux-androideabi-nm"
      cmd << "STRIP=#{@ndk.toolchain}/bin/arm-linux-androideabi-strip"
      cmd << "CHOST=arm-linux-androideabi"
      cmd << "CPPFLAGS=\"#{archFlags} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing\""
      cmd << "CXXFLAGS=\"#{archFlags} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -frtti -fexceptions -std=c++11 -Wno-error=unused-command-line-argument\""
      cmd << "CFLAGS=\"#{archFlags} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing\""
      cmd << "LDFLAGS=\"#{ldFlags}\""

      execute cmd.join(" ") + " autoreconf -i"

      args = "--with-sysroot=#{@ndk.sources}/sysroot --with-zlib=#{@ndk.sources}/sysroot/usr --prefix=#{@installs} --host=arm-linux-androideabi --without-lzma --disable-static --enable-shared --without-http --without-html --without-ftp"
      execute cmd.join(" ") + " ./configure " + args
   end

   def executeBuild
      execute "cd #{@sources} && make libxml2.la"
   end

   def executeInstall
      execute "cd #{@sources} && make install-libLTLIBRARIES"
      execute "cd #{@sources}/include && make install"
   end

end
