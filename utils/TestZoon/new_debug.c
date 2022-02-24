#include <linux/module.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/debugfs.h>
#include <linux/fs.h>
#include <linux/uaccess.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("sahil aggarwal <sahil.agg15@gmail.com>");
MODULE_DESCRIPTION("Debugfs");

#define DIR_NAME 		"testdir"
#define ID_FILE_NAME 		"data"

#define DEFAULT_DATA 		"Hello World !!\n"
#define MAX_LEN			30

char *buff;
struct dentry *dir_entry,*id_entry;

static ssize_t read_id(struct file *,char __user *,size_t, loff_t *);
static ssize_t write_id(struct file *,const char __user *,size_t, loff_t *);

struct file_operations id_fops = {
	.owner = THIS_MODULE,
	.read = read_id,
	.write = write_id
};


int create_entry(void)
{
	dir_entry = debugfs_create_dir(DIR_NAME,NULL);

	if(dir_entry == NULL)
	{
		printk(KERN_WARNING "Error in creating dir\n");
		return -1;
	}

	id_entry = debugfs_create_file(ID_FILE_NAME, 0666, dir_entry, buff, &id_fops);

	if(id_entry == NULL)
	{
		printk(KERN_WARNING "Erorr in creating id file\n");
		return -1;
	}
	
	return 0;
}

static ssize_t read_id(struct file *filp,char __user *user,size_t count,loff_t *offs)
{
	return simple_read_from_buffer(user,count,offs,buff,strlen(buff));
}

static ssize_t write_id(struct file *filp, const char __user *user, size_t count, loff_t *offs)
{
	int write_len = MAX_LEN - 1;

	if(count < MAX_LEN) 
		write_len = count;

	buff[count] = '\0';
	simple_write_to_buffer(buff, write_len, offs, user, write_len);

	return count;
}

static int __init hello_init(void)
{
	printk(KERN_DEBUG "Eudyptula debugfs...\n");
		
	buff = kmalloc(MAX_LEN, GFP_KERNEL);
	buff = strcpy(buff, DEFAULT_DATA);

	if(create_entry()) 
		printk(KERN_WARNING "Failed to create debugfs entry\n");	

	return 0;
}

static void __exit hello_exit(void)
{
	printk(KERN_DEBUG "Exiting...\n");
	debugfs_remove_recursive(dir_entry);	
	printk(KERN_DEBUG "Exiting Done\n");
}

module_init(hello_init);
module_exit(hello_exit);
