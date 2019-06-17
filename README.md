# Si5345_VIO_Config

这个工程是通过 Xilinx 的 VIO 向 FPGA 发送数据，然后配置片外的 Si5345，经测试成功。

# 使用方法

1. 新建一个空的工程，选择好目标的器件，这里我选的是 xc7k410tffg900-2L

2. 把代码下载下来，在 script 文件夹下面找到 vivado_import_si5345_config.tcl 文件，修改里面的 文件夹路径和器件型号

3. 在新的工程中 运行上面修改好的 tcl

   ![](https://raw.githubusercontent.com/wyu0725/My_Pic_bed/master/img/Si5345_Run_tcl.png)

   4. 如果器件不一样的话，请在 IP Core 中搜索 VIO 然后按如下配置

      ![](https://raw.githubusercontent.com/wyu0725/My_Pic_bed/master/img/Si5345_VIO1.png)

      ![](https://raw.githubusercontent.com/wyu0725/My_Pic_bed/master/img/SI5345_VIO2.png)

      ![](https://raw.githubusercontent.com/wyu0725/My_Pic_bed/master/img/SI5345_VIO3.png)

      5. 先综合，然后添加管脚分配文件，在 source/constrain 中，添加好之后生成 bit 流
      6. 烧好之后就可以运行 ReadSi5345Configuration.tcl