#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0x36d56703, __VMLINUX_SYMBOL_STR(module_layout) },
	{ 0x8e6121bc, __VMLINUX_SYMBOL_STR(debugfs_remove_recursive) },
	{ 0x99b3497b, __VMLINUX_SYMBOL_STR(kmem_cache_alloc_trace) },
	{ 0xc4db605b, __VMLINUX_SYMBOL_STR(kmalloc_caches) },
	{ 0x27e1a049, __VMLINUX_SYMBOL_STR(printk) },
	{ 0x87db8858, __VMLINUX_SYMBOL_STR(debugfs_create_file) },
	{ 0x2a1e63e4, __VMLINUX_SYMBOL_STR(debugfs_create_dir) },
	{ 0x619cb7dd, __VMLINUX_SYMBOL_STR(simple_read_from_buffer) },
	{ 0x754d539c, __VMLINUX_SYMBOL_STR(strlen) },
	{ 0xbb4f4766, __VMLINUX_SYMBOL_STR(simple_write_to_buffer) },
	{ 0xbdfb6dbb, __VMLINUX_SYMBOL_STR(__fentry__) },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";

