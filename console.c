// Console input and output.
// Input is from the keyboard or serial port.
// Output is written to the screen and serial port.

#include "types.h"
#include "defs.h"
#include "param.h"
#include "traps.h"
#include "spinlock.h"
#include "fs.h"
#include "file.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"

static void consputc(int);

static int panicked = 0;

static struct {
  struct spinlock lock;
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
  else
    x = xx;

  i = 0;
  do{
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
    consputc(buf[i]);
}
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    if(c != '%'){
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
    case '%':
      consputc('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
      consputc(c);
      break;
    }
  }

  if(locking)
    release(&cons.lock);
}

void
panic(char *s)
{
  int i;
  uint pcs[10];
  
  cli();
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
  for(;;)
    ;
}

//PAGEBREAK: 50
#define BACKSPACE 0x100
#define CRTPORT 0x3d4
#define UP_ARROW 0xE2
#define DOWN_ARROW 0xE3
#define LEFT_ARROW 0xE4
#define RIGHT_ARROW 0xE5


#define INPUT_BUF 128
#define MAX_HISTORY 16
typedef struct history {
    int current;
    int size;
    char buf[MAX_HISTORY][INPUT_BUF];
} classHistory;

classHistory inputHistory;

void history_insert(classHistory* pHistory,char* line ){
    memmove(pHistory->buf[1] ,pHistory->buf , INPUT_BUF*(MAX_HISTORY - 1));
    memmove(pHistory->buf,line, INPUT_BUF);
    if(pHistory->size < MAX_HISTORY - 1) pHistory->size++;
}

char* history_get(classHistory* pHistory, int index ){
    if(index >= pHistory->size || index <0) return 0;
    return pHistory->buf[index];
}

int history_get_string_size(char* str){
  int counter =0;
  while(str[counter]!='\n'){
    counter++;
  }
  return counter;
}

int history(char* buffer,int historyId){
  if(historyId >= MAX_HISTORY || historyId < 0) return -2;
  if(historyId > inputHistory.size) return -1;
  char* tmp = history_get(&inputHistory,historyId);
  if(tmp == 0) return -1;
  memmove(buffer,tmp,history_get_string_size(tmp));
//   memset(buffer+history_get_string_size(tmp)+1,'\0',1);
  return 0;
}

// void print_all_history(){
//   
//   int counter=0;
//   while(counter<inputHistory.size){
//     
//   }
// }
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
  pos = inb(CRTPORT+1) << 8;
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
    if(pos > 0){
      --pos;
      memmove(crt + pos, crt+pos + 1, sizeof(crt[0])*23*80 - pos);
    }
  }
  else if(c == LEFT_ARROW){
    if(pos > 0) pos--;
  }
  else if(c == RIGHT_ARROW){
    if(pos < sizeof(crt[0])*23*80) ++pos;
  }
  else if(c == UP_ARROW){
   if(inputHistory.current < inputHistory.size) {
       int todelete = pos%80 -2;
       pos -= todelete;
       int counter =0;
       int size = history_get_string_size(inputHistory.buf[inputHistory.current]);
       while(counter<size){
	crt[pos]=(inputHistory.buf[inputHistory.current][counter]&0xff) | 0x0700;
	pos++;
	counter++;
       }
       while(counter < todelete){
	 crt[pos + todelete - counter -1]=' ' | 0x0700;
	 counter++;
       }
   }
  }
  else if(c == DOWN_ARROW){
   if(inputHistory.current >= 0) {
       int todelete = pos%80 -2;
       pos -= todelete;
       int counter =0;
       int size = history_get_string_size(inputHistory.buf[inputHistory.current]);
       while(counter<size){
	crt[pos]=(inputHistory.buf[inputHistory.current][counter]&0xff) | 0x0700;
	pos++;
	counter++;
       }
       while(counter < todelete){
	 crt[pos + todelete - counter -1]=' ' | 0x0700;
	 counter++;
       }
   }
   else{
     int todelete = pos%80 -2;
       pos -= todelete;
       int counter =0;
       while(counter < todelete){
	 crt[pos + todelete - counter -1]=' ' | 0x0700;
	 counter++;
       }
   }
  }
  else{
    memmove(crt + pos + 1, crt+pos, sizeof(crt[0])*23*80 - pos);
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
  }
    

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");
  
  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  }
  
  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);
  //crt[pos] = ' ' | 0x0700; //removed so there won't be a white space
}

void
consputc(int c)
{
  if(panicked){
    cli();
    for(;;)
      ;
  }
  
  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
  }
  else
    uartputc(c);
  cgaputc(c);
}

struct {
  char buf[INPUT_BUF];
  uint r;  // Read index
  uint w;  // Write index
  uint e;  // Edit index
  uint c;  // Current index
} input;

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;
  //int counter=0;
  acquire(&cons.lock);
  while((c = getc()) >= 0){
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.c--;
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
	input.c--;
	memmove(input.buf + (input.c % INPUT_BUF), input.buf + (input.c % INPUT_BUF) + 1, INPUT_BUF - input.c);
        consputc(BACKSPACE);
      }
      break;
    case LEFT_ARROW:
      if(input.c > input.w){
        input.c--;
	consputc(LEFT_ARROW);
      }
      break;   
      
    case RIGHT_ARROW:
      if(input.c < input.e){
        input.c++;
	consputc(RIGHT_ARROW);
      }
      break;
     case UP_ARROW:
       if(inputHistory.current < inputHistory.size - 1 && inputHistory.size > 0){  
	    inputHistory.current++;
	    memmove(input.buf + input.r , inputHistory.buf[inputHistory.current], history_get_string_size(inputHistory.buf[inputHistory.current]));
	    input.e = input.r + history_get_string_size(inputHistory.buf[inputHistory.current]);
	    input.c = input.e;
	    consputc(UP_ARROW);

       }
      break;
      case DOWN_ARROW:
	if(inputHistory.current > 0){  
	    inputHistory.current--;
	    memmove(input.buf + input.r , inputHistory.buf[inputHistory.current], history_get_string_size(inputHistory.buf[inputHistory.current]));
	    input.e = input.r + history_get_string_size(inputHistory.buf[inputHistory.current]);
	    input.c = input.e;
	    consputc(DOWN_ARROW);

	}   
	else if(inputHistory.current == 0){  
	    inputHistory.current--;
	    input.e = input.r ;
	    input.c = input.e;
	    consputc(DOWN_ARROW);
	}   
	break;
      
      
      
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
	inputHistory.current = -1;
	if(c == '\n'){
	  input.buf[input.e++ % INPUT_BUF] = c;
	}else{
	  memmove(input.buf + (input.c % INPUT_BUF) + 1, input.buf + (input.c % INPUT_BUF), INPUT_BUF - input.c - 1);
	  input.buf[input.c++ % INPUT_BUF] = c;
	  input.e++;
	}
        consputc(c);
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
	  history_insert(&inputHistory,input.buf+input.r);
          input.w = input.e;
	  input.c = input.e;
          wakeup(&input.r);
        }
      }
      break;
    }
  }
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
  uint target;
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
      if(proc->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
    if(c == C('D')){  // EOF
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
    
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
    consputc(buf[i] & 0xff);
  release(&cons.lock);
  ilock(ip);

  return n;
}

void
consoleinit(void)
{
  initlock(&cons.lock, "console");

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  picenable(IRQ_KBD);
  ioapicenable(IRQ_KBD, 0);
  
  inputHistory.size = 0;
  inputHistory.current = -1;
}

