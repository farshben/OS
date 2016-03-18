#include "types.h" 
#include "user.h" 
#include "syscall.h" 

int main(int argc, char *argv[]) 
{ 
  int a=1;
  int b=1;
  int c=1;
  int d;
  int* retime=&a;
  int* rutime=&b;
  int* stime=&c;
  int pid;
  
    int k=0;
    while(k<10){
      k++;
      if((pid=fork())!=0){
      pid=wait2(retime,rutime,stime);
//       printf(1,"Process id= %d\n",pid);
//       printf(1,"Run= %d\n",*rutime);
//       printf(1,"Ready= %d\n",*retime);
//       printf(1,"Sleep= %d\n",*stime);
    }
    else {
      d=0;
      while(d<15){d++;}
    }
    }

  exit(); 
  
} 
