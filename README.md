# fiotest
* 配置信息	
	* OS：	Centos6.5_x64
	* Kernel：	2.6.32-220.el6.x86_64
	* Compiler：	GCC 4.4.6
  	* parted 分区 4MB 起始（解决4k对齐问题）

* 代码结构
	* fiotest
		* autotest.sh 程序开始文件
		* data 数据存储位置
		* script 脚本库
			* function.sh 测试函数库
			* expect expect交互函数目录
			* project 测试项（旧测试方法）
			* testPoint 测试点（旧测试方法）
			* health 测试硬盘寿命信息
				* health.sh 寿命测试开始文件
				* health_function.sh 寿命测试函数库
				* health_expect.sh 寿命测试交互函数目录

* 使用方法：
  * 使用fdisk -l 命令查看ssd名称
  * 执行脚本，命令为./autotest ssd名称
* 版本信息：
  * 1.0版本采用bash shell作为开发语言，预计2.0版本开始使用Python
  * 1.1版本采用新的ssd测评方案，并在function.sh 中加入了数据收集函数（collect_data）
