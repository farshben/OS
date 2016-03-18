
_t:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h" 
#include "user.h" 
#include "syscall.h" 

int main(int argc, char *argv[]) 
{ 
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 40             	sub    $0x40,%esp
  int a=1;
   9:	c7 44 24 24 01 00 00 	movl   $0x1,0x24(%esp)
  10:	00 
  int b=1;
  11:	c7 44 24 20 01 00 00 	movl   $0x1,0x20(%esp)
  18:	00 
  int c=1;
  19:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  20:	00 
  int d;
  int* retime=&a;
  21:	8d 44 24 24          	lea    0x24(%esp),%eax
  25:	89 44 24 34          	mov    %eax,0x34(%esp)
  int* rutime=&b;
  29:	8d 44 24 20          	lea    0x20(%esp),%eax
  2d:	89 44 24 30          	mov    %eax,0x30(%esp)
  int* stime=&c;
  31:	8d 44 24 1c          	lea    0x1c(%esp),%eax
  35:	89 44 24 2c          	mov    %eax,0x2c(%esp)
  int pid;
  
    int k=0;
  39:	c7 44 24 38 00 00 00 	movl   $0x0,0x38(%esp)
  40:	00 
    while(k<10){
  41:	eb 4d                	jmp    90 <main+0x90>
      k++;
  43:	83 44 24 38 01       	addl   $0x1,0x38(%esp)
      if((pid=fork())!=0){
  48:	e8 af 02 00 00       	call   2fc <fork>
  4d:	89 44 24 28          	mov    %eax,0x28(%esp)
  51:	83 7c 24 28 00       	cmpl   $0x0,0x28(%esp)
  56:	74 22                	je     7a <main+0x7a>
      pid=wait2(retime,rutime,stime);
  58:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  60:	8b 44 24 30          	mov    0x30(%esp),%eax
  64:	89 44 24 04          	mov    %eax,0x4(%esp)
  68:	8b 44 24 34          	mov    0x34(%esp),%eax
  6c:	89 04 24             	mov    %eax,(%esp)
  6f:	e8 38 03 00 00       	call   3ac <wait2>
  74:	89 44 24 28          	mov    %eax,0x28(%esp)
  78:	eb 16                	jmp    90 <main+0x90>
//       printf(1,"Run= %d\n",*rutime);
//       printf(1,"Ready= %d\n",*retime);
//       printf(1,"Sleep= %d\n",*stime);
    }
    else {
      d=0;
  7a:	c7 44 24 3c 00 00 00 	movl   $0x0,0x3c(%esp)
  81:	00 
      while(d<15){d++;}
  82:	eb 05                	jmp    89 <main+0x89>
  84:	83 44 24 3c 01       	addl   $0x1,0x3c(%esp)
  89:	83 7c 24 3c 0e       	cmpl   $0xe,0x3c(%esp)
  8e:	7e f4                	jle    84 <main+0x84>
  int* rutime=&b;
  int* stime=&c;
  int pid;
  
    int k=0;
    while(k<10){
  90:	83 7c 24 38 09       	cmpl   $0x9,0x38(%esp)
  95:	7e ac                	jle    43 <main+0x43>
      d=0;
      while(d<15){d++;}
    }
    }

  exit(); 
  97:	e8 68 02 00 00       	call   304 <exit>

0000009c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  9c:	55                   	push   %ebp
  9d:	89 e5                	mov    %esp,%ebp
  9f:	57                   	push   %edi
  a0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  a4:	8b 55 10             	mov    0x10(%ebp),%edx
  a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  aa:	89 cb                	mov    %ecx,%ebx
  ac:	89 df                	mov    %ebx,%edi
  ae:	89 d1                	mov    %edx,%ecx
  b0:	fc                   	cld    
  b1:	f3 aa                	rep stos %al,%es:(%edi)
  b3:	89 ca                	mov    %ecx,%edx
  b5:	89 fb                	mov    %edi,%ebx
  b7:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ba:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  bd:	5b                   	pop    %ebx
  be:	5f                   	pop    %edi
  bf:	5d                   	pop    %ebp
  c0:	c3                   	ret    

000000c1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  c1:	55                   	push   %ebp
  c2:	89 e5                	mov    %esp,%ebp
  c4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  c7:	8b 45 08             	mov    0x8(%ebp),%eax
  ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  cd:	90                   	nop
  ce:	8b 45 08             	mov    0x8(%ebp),%eax
  d1:	8d 50 01             	lea    0x1(%eax),%edx
  d4:	89 55 08             	mov    %edx,0x8(%ebp)
  d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  da:	8d 4a 01             	lea    0x1(%edx),%ecx
  dd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  e0:	0f b6 12             	movzbl (%edx),%edx
  e3:	88 10                	mov    %dl,(%eax)
  e5:	0f b6 00             	movzbl (%eax),%eax
  e8:	84 c0                	test   %al,%al
  ea:	75 e2                	jne    ce <strcpy+0xd>
    ;
  return os;
  ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  ef:	c9                   	leave  
  f0:	c3                   	ret    

000000f1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f1:	55                   	push   %ebp
  f2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  f4:	eb 08                	jmp    fe <strcmp+0xd>
    p++, q++;
  f6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  fa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  fe:	8b 45 08             	mov    0x8(%ebp),%eax
 101:	0f b6 00             	movzbl (%eax),%eax
 104:	84 c0                	test   %al,%al
 106:	74 10                	je     118 <strcmp+0x27>
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	0f b6 10             	movzbl (%eax),%edx
 10e:	8b 45 0c             	mov    0xc(%ebp),%eax
 111:	0f b6 00             	movzbl (%eax),%eax
 114:	38 c2                	cmp    %al,%dl
 116:	74 de                	je     f6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	0f b6 00             	movzbl (%eax),%eax
 11e:	0f b6 d0             	movzbl %al,%edx
 121:	8b 45 0c             	mov    0xc(%ebp),%eax
 124:	0f b6 00             	movzbl (%eax),%eax
 127:	0f b6 c0             	movzbl %al,%eax
 12a:	29 c2                	sub    %eax,%edx
 12c:	89 d0                	mov    %edx,%eax
}
 12e:	5d                   	pop    %ebp
 12f:	c3                   	ret    

00000130 <strlen>:

uint
strlen(char *s)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 136:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 13d:	eb 04                	jmp    143 <strlen+0x13>
 13f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 143:	8b 55 fc             	mov    -0x4(%ebp),%edx
 146:	8b 45 08             	mov    0x8(%ebp),%eax
 149:	01 d0                	add    %edx,%eax
 14b:	0f b6 00             	movzbl (%eax),%eax
 14e:	84 c0                	test   %al,%al
 150:	75 ed                	jne    13f <strlen+0xf>
    ;
  return n;
 152:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 155:	c9                   	leave  
 156:	c3                   	ret    

00000157 <memset>:

void*
memset(void *dst, int c, uint n)
{
 157:	55                   	push   %ebp
 158:	89 e5                	mov    %esp,%ebp
 15a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 15d:	8b 45 10             	mov    0x10(%ebp),%eax
 160:	89 44 24 08          	mov    %eax,0x8(%esp)
 164:	8b 45 0c             	mov    0xc(%ebp),%eax
 167:	89 44 24 04          	mov    %eax,0x4(%esp)
 16b:	8b 45 08             	mov    0x8(%ebp),%eax
 16e:	89 04 24             	mov    %eax,(%esp)
 171:	e8 26 ff ff ff       	call   9c <stosb>
  return dst;
 176:	8b 45 08             	mov    0x8(%ebp),%eax
}
 179:	c9                   	leave  
 17a:	c3                   	ret    

0000017b <strchr>:

char*
strchr(const char *s, char c)
{
 17b:	55                   	push   %ebp
 17c:	89 e5                	mov    %esp,%ebp
 17e:	83 ec 04             	sub    $0x4,%esp
 181:	8b 45 0c             	mov    0xc(%ebp),%eax
 184:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 187:	eb 14                	jmp    19d <strchr+0x22>
    if(*s == c)
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	0f b6 00             	movzbl (%eax),%eax
 18f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 192:	75 05                	jne    199 <strchr+0x1e>
      return (char*)s;
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	eb 13                	jmp    1ac <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 199:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 19d:	8b 45 08             	mov    0x8(%ebp),%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	84 c0                	test   %al,%al
 1a5:	75 e2                	jne    189 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1ac:	c9                   	leave  
 1ad:	c3                   	ret    

000001ae <gets>:

char*
gets(char *buf, int max)
{
 1ae:	55                   	push   %ebp
 1af:	89 e5                	mov    %esp,%ebp
 1b1:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1bb:	eb 4c                	jmp    209 <gets+0x5b>
    cc = read(0, &c, 1);
 1bd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1c4:	00 
 1c5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1c8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1d3:	e8 44 01 00 00       	call   31c <read>
 1d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1df:	7f 02                	jg     1e3 <gets+0x35>
      break;
 1e1:	eb 31                	jmp    214 <gets+0x66>
    buf[i++] = c;
 1e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e6:	8d 50 01             	lea    0x1(%eax),%edx
 1e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1ec:	89 c2                	mov    %eax,%edx
 1ee:	8b 45 08             	mov    0x8(%ebp),%eax
 1f1:	01 c2                	add    %eax,%edx
 1f3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f7:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1f9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1fd:	3c 0a                	cmp    $0xa,%al
 1ff:	74 13                	je     214 <gets+0x66>
 201:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 205:	3c 0d                	cmp    $0xd,%al
 207:	74 0b                	je     214 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 209:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20c:	83 c0 01             	add    $0x1,%eax
 20f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 212:	7c a9                	jl     1bd <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 214:	8b 55 f4             	mov    -0xc(%ebp),%edx
 217:	8b 45 08             	mov    0x8(%ebp),%eax
 21a:	01 d0                	add    %edx,%eax
 21c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 21f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 222:	c9                   	leave  
 223:	c3                   	ret    

00000224 <stat>:

int
stat(char *n, struct stat *st)
{
 224:	55                   	push   %ebp
 225:	89 e5                	mov    %esp,%ebp
 227:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 231:	00 
 232:	8b 45 08             	mov    0x8(%ebp),%eax
 235:	89 04 24             	mov    %eax,(%esp)
 238:	e8 07 01 00 00       	call   344 <open>
 23d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 240:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 244:	79 07                	jns    24d <stat+0x29>
    return -1;
 246:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 24b:	eb 23                	jmp    270 <stat+0x4c>
  r = fstat(fd, st);
 24d:	8b 45 0c             	mov    0xc(%ebp),%eax
 250:	89 44 24 04          	mov    %eax,0x4(%esp)
 254:	8b 45 f4             	mov    -0xc(%ebp),%eax
 257:	89 04 24             	mov    %eax,(%esp)
 25a:	e8 fd 00 00 00       	call   35c <fstat>
 25f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 262:	8b 45 f4             	mov    -0xc(%ebp),%eax
 265:	89 04 24             	mov    %eax,(%esp)
 268:	e8 bf 00 00 00       	call   32c <close>
  return r;
 26d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 270:	c9                   	leave  
 271:	c3                   	ret    

00000272 <atoi>:

int
atoi(const char *s)
{
 272:	55                   	push   %ebp
 273:	89 e5                	mov    %esp,%ebp
 275:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 278:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 27f:	eb 25                	jmp    2a6 <atoi+0x34>
    n = n*10 + *s++ - '0';
 281:	8b 55 fc             	mov    -0x4(%ebp),%edx
 284:	89 d0                	mov    %edx,%eax
 286:	c1 e0 02             	shl    $0x2,%eax
 289:	01 d0                	add    %edx,%eax
 28b:	01 c0                	add    %eax,%eax
 28d:	89 c1                	mov    %eax,%ecx
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	8d 50 01             	lea    0x1(%eax),%edx
 295:	89 55 08             	mov    %edx,0x8(%ebp)
 298:	0f b6 00             	movzbl (%eax),%eax
 29b:	0f be c0             	movsbl %al,%eax
 29e:	01 c8                	add    %ecx,%eax
 2a0:	83 e8 30             	sub    $0x30,%eax
 2a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2a6:	8b 45 08             	mov    0x8(%ebp),%eax
 2a9:	0f b6 00             	movzbl (%eax),%eax
 2ac:	3c 2f                	cmp    $0x2f,%al
 2ae:	7e 0a                	jle    2ba <atoi+0x48>
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
 2b3:	0f b6 00             	movzbl (%eax),%eax
 2b6:	3c 39                	cmp    $0x39,%al
 2b8:	7e c7                	jle    281 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2bd:	c9                   	leave  
 2be:	c3                   	ret    

000002bf <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2bf:	55                   	push   %ebp
 2c0:	89 e5                	mov    %esp,%ebp
 2c2:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
 2c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ce:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2d1:	eb 17                	jmp    2ea <memmove+0x2b>
    *dst++ = *src++;
 2d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2d6:	8d 50 01             	lea    0x1(%eax),%edx
 2d9:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2dc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2df:	8d 4a 01             	lea    0x1(%edx),%ecx
 2e2:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2e5:	0f b6 12             	movzbl (%edx),%edx
 2e8:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2ea:	8b 45 10             	mov    0x10(%ebp),%eax
 2ed:	8d 50 ff             	lea    -0x1(%eax),%edx
 2f0:	89 55 10             	mov    %edx,0x10(%ebp)
 2f3:	85 c0                	test   %eax,%eax
 2f5:	7f dc                	jg     2d3 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2fa:	c9                   	leave  
 2fb:	c3                   	ret    

000002fc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2fc:	b8 01 00 00 00       	mov    $0x1,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <exit>:
SYSCALL(exit)
 304:	b8 02 00 00 00       	mov    $0x2,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <wait>:
SYSCALL(wait)
 30c:	b8 03 00 00 00       	mov    $0x3,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <pipe>:
SYSCALL(pipe)
 314:	b8 04 00 00 00       	mov    $0x4,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <read>:
SYSCALL(read)
 31c:	b8 05 00 00 00       	mov    $0x5,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <write>:
SYSCALL(write)
 324:	b8 10 00 00 00       	mov    $0x10,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <close>:
SYSCALL(close)
 32c:	b8 15 00 00 00       	mov    $0x15,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <kill>:
SYSCALL(kill)
 334:	b8 06 00 00 00       	mov    $0x6,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <exec>:
SYSCALL(exec)
 33c:	b8 07 00 00 00       	mov    $0x7,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <open>:
SYSCALL(open)
 344:	b8 0f 00 00 00       	mov    $0xf,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <mknod>:
SYSCALL(mknod)
 34c:	b8 11 00 00 00       	mov    $0x11,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <unlink>:
SYSCALL(unlink)
 354:	b8 12 00 00 00       	mov    $0x12,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <fstat>:
SYSCALL(fstat)
 35c:	b8 08 00 00 00       	mov    $0x8,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <link>:
SYSCALL(link)
 364:	b8 13 00 00 00       	mov    $0x13,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <mkdir>:
SYSCALL(mkdir)
 36c:	b8 14 00 00 00       	mov    $0x14,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <chdir>:
SYSCALL(chdir)
 374:	b8 09 00 00 00       	mov    $0x9,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <dup>:
SYSCALL(dup)
 37c:	b8 0a 00 00 00       	mov    $0xa,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <getpid>:
SYSCALL(getpid)
 384:	b8 0b 00 00 00       	mov    $0xb,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <sbrk>:
SYSCALL(sbrk)
 38c:	b8 0c 00 00 00       	mov    $0xc,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <sleep>:
SYSCALL(sleep)
 394:	b8 0d 00 00 00       	mov    $0xd,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <uptime>:
SYSCALL(uptime)
 39c:	b8 0e 00 00 00       	mov    $0xe,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <history>:
SYSCALL(history)
 3a4:	b8 16 00 00 00       	mov    $0x16,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <wait2>:
SYSCALL(wait2)
 3ac:	b8 17 00 00 00       	mov    $0x17,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b4:	55                   	push   %ebp
 3b5:	89 e5                	mov    %esp,%ebp
 3b7:	83 ec 18             	sub    $0x18,%esp
 3ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3c0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3c7:	00 
 3c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3cb:	89 44 24 04          	mov    %eax,0x4(%esp)
 3cf:	8b 45 08             	mov    0x8(%ebp),%eax
 3d2:	89 04 24             	mov    %eax,(%esp)
 3d5:	e8 4a ff ff ff       	call   324 <write>
}
 3da:	c9                   	leave  
 3db:	c3                   	ret    

000003dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3dc:	55                   	push   %ebp
 3dd:	89 e5                	mov    %esp,%ebp
 3df:	56                   	push   %esi
 3e0:	53                   	push   %ebx
 3e1:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3eb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3ef:	74 17                	je     408 <printint+0x2c>
 3f1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3f5:	79 11                	jns    408 <printint+0x2c>
    neg = 1;
 3f7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 401:	f7 d8                	neg    %eax
 403:	89 45 ec             	mov    %eax,-0x14(%ebp)
 406:	eb 06                	jmp    40e <printint+0x32>
  } else {
    x = xx;
 408:	8b 45 0c             	mov    0xc(%ebp),%eax
 40b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 40e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 415:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 418:	8d 41 01             	lea    0x1(%ecx),%eax
 41b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 41e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 421:	8b 45 ec             	mov    -0x14(%ebp),%eax
 424:	ba 00 00 00 00       	mov    $0x0,%edx
 429:	f7 f3                	div    %ebx
 42b:	89 d0                	mov    %edx,%eax
 42d:	0f b6 80 ac 0a 00 00 	movzbl 0xaac(%eax),%eax
 434:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 438:	8b 75 10             	mov    0x10(%ebp),%esi
 43b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 43e:	ba 00 00 00 00       	mov    $0x0,%edx
 443:	f7 f6                	div    %esi
 445:	89 45 ec             	mov    %eax,-0x14(%ebp)
 448:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 44c:	75 c7                	jne    415 <printint+0x39>
  if(neg)
 44e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 452:	74 10                	je     464 <printint+0x88>
    buf[i++] = '-';
 454:	8b 45 f4             	mov    -0xc(%ebp),%eax
 457:	8d 50 01             	lea    0x1(%eax),%edx
 45a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 45d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 462:	eb 1f                	jmp    483 <printint+0xa7>
 464:	eb 1d                	jmp    483 <printint+0xa7>
    putc(fd, buf[i]);
 466:	8d 55 dc             	lea    -0x24(%ebp),%edx
 469:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46c:	01 d0                	add    %edx,%eax
 46e:	0f b6 00             	movzbl (%eax),%eax
 471:	0f be c0             	movsbl %al,%eax
 474:	89 44 24 04          	mov    %eax,0x4(%esp)
 478:	8b 45 08             	mov    0x8(%ebp),%eax
 47b:	89 04 24             	mov    %eax,(%esp)
 47e:	e8 31 ff ff ff       	call   3b4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 483:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 487:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 48b:	79 d9                	jns    466 <printint+0x8a>
    putc(fd, buf[i]);
}
 48d:	83 c4 30             	add    $0x30,%esp
 490:	5b                   	pop    %ebx
 491:	5e                   	pop    %esi
 492:	5d                   	pop    %ebp
 493:	c3                   	ret    

00000494 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 494:	55                   	push   %ebp
 495:	89 e5                	mov    %esp,%ebp
 497:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 49a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4a1:	8d 45 0c             	lea    0xc(%ebp),%eax
 4a4:	83 c0 04             	add    $0x4,%eax
 4a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4b1:	e9 7c 01 00 00       	jmp    632 <printf+0x19e>
    c = fmt[i] & 0xff;
 4b6:	8b 55 0c             	mov    0xc(%ebp),%edx
 4b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4bc:	01 d0                	add    %edx,%eax
 4be:	0f b6 00             	movzbl (%eax),%eax
 4c1:	0f be c0             	movsbl %al,%eax
 4c4:	25 ff 00 00 00       	and    $0xff,%eax
 4c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4d0:	75 2c                	jne    4fe <printf+0x6a>
      if(c == '%'){
 4d2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4d6:	75 0c                	jne    4e4 <printf+0x50>
        state = '%';
 4d8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4df:	e9 4a 01 00 00       	jmp    62e <printf+0x19a>
      } else {
        putc(fd, c);
 4e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4e7:	0f be c0             	movsbl %al,%eax
 4ea:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ee:	8b 45 08             	mov    0x8(%ebp),%eax
 4f1:	89 04 24             	mov    %eax,(%esp)
 4f4:	e8 bb fe ff ff       	call   3b4 <putc>
 4f9:	e9 30 01 00 00       	jmp    62e <printf+0x19a>
      }
    } else if(state == '%'){
 4fe:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 502:	0f 85 26 01 00 00    	jne    62e <printf+0x19a>
      if(c == 'd'){
 508:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 50c:	75 2d                	jne    53b <printf+0xa7>
        printint(fd, *ap, 10, 1);
 50e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 511:	8b 00                	mov    (%eax),%eax
 513:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 51a:	00 
 51b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 522:	00 
 523:	89 44 24 04          	mov    %eax,0x4(%esp)
 527:	8b 45 08             	mov    0x8(%ebp),%eax
 52a:	89 04 24             	mov    %eax,(%esp)
 52d:	e8 aa fe ff ff       	call   3dc <printint>
        ap++;
 532:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 536:	e9 ec 00 00 00       	jmp    627 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 53b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 53f:	74 06                	je     547 <printf+0xb3>
 541:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 545:	75 2d                	jne    574 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 547:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54a:	8b 00                	mov    (%eax),%eax
 54c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 553:	00 
 554:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 55b:	00 
 55c:	89 44 24 04          	mov    %eax,0x4(%esp)
 560:	8b 45 08             	mov    0x8(%ebp),%eax
 563:	89 04 24             	mov    %eax,(%esp)
 566:	e8 71 fe ff ff       	call   3dc <printint>
        ap++;
 56b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 56f:	e9 b3 00 00 00       	jmp    627 <printf+0x193>
      } else if(c == 's'){
 574:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 578:	75 45                	jne    5bf <printf+0x12b>
        s = (char*)*ap;
 57a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 57d:	8b 00                	mov    (%eax),%eax
 57f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 582:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 586:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 58a:	75 09                	jne    595 <printf+0x101>
          s = "(null)";
 58c:	c7 45 f4 60 08 00 00 	movl   $0x860,-0xc(%ebp)
        while(*s != 0){
 593:	eb 1e                	jmp    5b3 <printf+0x11f>
 595:	eb 1c                	jmp    5b3 <printf+0x11f>
          putc(fd, *s);
 597:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59a:	0f b6 00             	movzbl (%eax),%eax
 59d:	0f be c0             	movsbl %al,%eax
 5a0:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a4:	8b 45 08             	mov    0x8(%ebp),%eax
 5a7:	89 04 24             	mov    %eax,(%esp)
 5aa:	e8 05 fe ff ff       	call   3b4 <putc>
          s++;
 5af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b6:	0f b6 00             	movzbl (%eax),%eax
 5b9:	84 c0                	test   %al,%al
 5bb:	75 da                	jne    597 <printf+0x103>
 5bd:	eb 68                	jmp    627 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5bf:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5c3:	75 1d                	jne    5e2 <printf+0x14e>
        putc(fd, *ap);
 5c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c8:	8b 00                	mov    (%eax),%eax
 5ca:	0f be c0             	movsbl %al,%eax
 5cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d1:	8b 45 08             	mov    0x8(%ebp),%eax
 5d4:	89 04 24             	mov    %eax,(%esp)
 5d7:	e8 d8 fd ff ff       	call   3b4 <putc>
        ap++;
 5dc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5e0:	eb 45                	jmp    627 <printf+0x193>
      } else if(c == '%'){
 5e2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5e6:	75 17                	jne    5ff <printf+0x16b>
        putc(fd, c);
 5e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5eb:	0f be c0             	movsbl %al,%eax
 5ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f2:	8b 45 08             	mov    0x8(%ebp),%eax
 5f5:	89 04 24             	mov    %eax,(%esp)
 5f8:	e8 b7 fd ff ff       	call   3b4 <putc>
 5fd:	eb 28                	jmp    627 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ff:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 606:	00 
 607:	8b 45 08             	mov    0x8(%ebp),%eax
 60a:	89 04 24             	mov    %eax,(%esp)
 60d:	e8 a2 fd ff ff       	call   3b4 <putc>
        putc(fd, c);
 612:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 615:	0f be c0             	movsbl %al,%eax
 618:	89 44 24 04          	mov    %eax,0x4(%esp)
 61c:	8b 45 08             	mov    0x8(%ebp),%eax
 61f:	89 04 24             	mov    %eax,(%esp)
 622:	e8 8d fd ff ff       	call   3b4 <putc>
      }
      state = 0;
 627:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 62e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 632:	8b 55 0c             	mov    0xc(%ebp),%edx
 635:	8b 45 f0             	mov    -0x10(%ebp),%eax
 638:	01 d0                	add    %edx,%eax
 63a:	0f b6 00             	movzbl (%eax),%eax
 63d:	84 c0                	test   %al,%al
 63f:	0f 85 71 fe ff ff    	jne    4b6 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 645:	c9                   	leave  
 646:	c3                   	ret    

00000647 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 647:	55                   	push   %ebp
 648:	89 e5                	mov    %esp,%ebp
 64a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 64d:	8b 45 08             	mov    0x8(%ebp),%eax
 650:	83 e8 08             	sub    $0x8,%eax
 653:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 656:	a1 c8 0a 00 00       	mov    0xac8,%eax
 65b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 65e:	eb 24                	jmp    684 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 660:	8b 45 fc             	mov    -0x4(%ebp),%eax
 663:	8b 00                	mov    (%eax),%eax
 665:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 668:	77 12                	ja     67c <free+0x35>
 66a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 670:	77 24                	ja     696 <free+0x4f>
 672:	8b 45 fc             	mov    -0x4(%ebp),%eax
 675:	8b 00                	mov    (%eax),%eax
 677:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 67a:	77 1a                	ja     696 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 67c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67f:	8b 00                	mov    (%eax),%eax
 681:	89 45 fc             	mov    %eax,-0x4(%ebp)
 684:	8b 45 f8             	mov    -0x8(%ebp),%eax
 687:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 68a:	76 d4                	jbe    660 <free+0x19>
 68c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68f:	8b 00                	mov    (%eax),%eax
 691:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 694:	76 ca                	jbe    660 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 696:	8b 45 f8             	mov    -0x8(%ebp),%eax
 699:	8b 40 04             	mov    0x4(%eax),%eax
 69c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a6:	01 c2                	add    %eax,%edx
 6a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ab:	8b 00                	mov    (%eax),%eax
 6ad:	39 c2                	cmp    %eax,%edx
 6af:	75 24                	jne    6d5 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b4:	8b 50 04             	mov    0x4(%eax),%edx
 6b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ba:	8b 00                	mov    (%eax),%eax
 6bc:	8b 40 04             	mov    0x4(%eax),%eax
 6bf:	01 c2                	add    %eax,%edx
 6c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c4:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ca:	8b 00                	mov    (%eax),%eax
 6cc:	8b 10                	mov    (%eax),%edx
 6ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d1:	89 10                	mov    %edx,(%eax)
 6d3:	eb 0a                	jmp    6df <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	8b 10                	mov    (%eax),%edx
 6da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6dd:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e2:	8b 40 04             	mov    0x4(%eax),%eax
 6e5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	01 d0                	add    %edx,%eax
 6f1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6f4:	75 20                	jne    716 <free+0xcf>
    p->s.size += bp->s.size;
 6f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f9:	8b 50 04             	mov    0x4(%eax),%edx
 6fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ff:	8b 40 04             	mov    0x4(%eax),%eax
 702:	01 c2                	add    %eax,%edx
 704:	8b 45 fc             	mov    -0x4(%ebp),%eax
 707:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 70a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70d:	8b 10                	mov    (%eax),%edx
 70f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 712:	89 10                	mov    %edx,(%eax)
 714:	eb 08                	jmp    71e <free+0xd7>
  } else
    p->s.ptr = bp;
 716:	8b 45 fc             	mov    -0x4(%ebp),%eax
 719:	8b 55 f8             	mov    -0x8(%ebp),%edx
 71c:	89 10                	mov    %edx,(%eax)
  freep = p;
 71e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 721:	a3 c8 0a 00 00       	mov    %eax,0xac8
}
 726:	c9                   	leave  
 727:	c3                   	ret    

00000728 <morecore>:

static Header*
morecore(uint nu)
{
 728:	55                   	push   %ebp
 729:	89 e5                	mov    %esp,%ebp
 72b:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 72e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 735:	77 07                	ja     73e <morecore+0x16>
    nu = 4096;
 737:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 73e:	8b 45 08             	mov    0x8(%ebp),%eax
 741:	c1 e0 03             	shl    $0x3,%eax
 744:	89 04 24             	mov    %eax,(%esp)
 747:	e8 40 fc ff ff       	call   38c <sbrk>
 74c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 74f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 753:	75 07                	jne    75c <morecore+0x34>
    return 0;
 755:	b8 00 00 00 00       	mov    $0x0,%eax
 75a:	eb 22                	jmp    77e <morecore+0x56>
  hp = (Header*)p;
 75c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 762:	8b 45 f0             	mov    -0x10(%ebp),%eax
 765:	8b 55 08             	mov    0x8(%ebp),%edx
 768:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 76b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76e:	83 c0 08             	add    $0x8,%eax
 771:	89 04 24             	mov    %eax,(%esp)
 774:	e8 ce fe ff ff       	call   647 <free>
  return freep;
 779:	a1 c8 0a 00 00       	mov    0xac8,%eax
}
 77e:	c9                   	leave  
 77f:	c3                   	ret    

00000780 <malloc>:

void*
malloc(uint nbytes)
{
 780:	55                   	push   %ebp
 781:	89 e5                	mov    %esp,%ebp
 783:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 786:	8b 45 08             	mov    0x8(%ebp),%eax
 789:	83 c0 07             	add    $0x7,%eax
 78c:	c1 e8 03             	shr    $0x3,%eax
 78f:	83 c0 01             	add    $0x1,%eax
 792:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 795:	a1 c8 0a 00 00       	mov    0xac8,%eax
 79a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 79d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7a1:	75 23                	jne    7c6 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7a3:	c7 45 f0 c0 0a 00 00 	movl   $0xac0,-0x10(%ebp)
 7aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ad:	a3 c8 0a 00 00       	mov    %eax,0xac8
 7b2:	a1 c8 0a 00 00       	mov    0xac8,%eax
 7b7:	a3 c0 0a 00 00       	mov    %eax,0xac0
    base.s.size = 0;
 7bc:	c7 05 c4 0a 00 00 00 	movl   $0x0,0xac4
 7c3:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c9:	8b 00                	mov    (%eax),%eax
 7cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d1:	8b 40 04             	mov    0x4(%eax),%eax
 7d4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7d7:	72 4d                	jb     826 <malloc+0xa6>
      if(p->s.size == nunits)
 7d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dc:	8b 40 04             	mov    0x4(%eax),%eax
 7df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7e2:	75 0c                	jne    7f0 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e7:	8b 10                	mov    (%eax),%edx
 7e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ec:	89 10                	mov    %edx,(%eax)
 7ee:	eb 26                	jmp    816 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f3:	8b 40 04             	mov    0x4(%eax),%eax
 7f6:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7f9:	89 c2                	mov    %eax,%edx
 7fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fe:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 801:	8b 45 f4             	mov    -0xc(%ebp),%eax
 804:	8b 40 04             	mov    0x4(%eax),%eax
 807:	c1 e0 03             	shl    $0x3,%eax
 80a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 80d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 810:	8b 55 ec             	mov    -0x14(%ebp),%edx
 813:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 816:	8b 45 f0             	mov    -0x10(%ebp),%eax
 819:	a3 c8 0a 00 00       	mov    %eax,0xac8
      return (void*)(p + 1);
 81e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 821:	83 c0 08             	add    $0x8,%eax
 824:	eb 38                	jmp    85e <malloc+0xde>
    }
    if(p == freep)
 826:	a1 c8 0a 00 00       	mov    0xac8,%eax
 82b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 82e:	75 1b                	jne    84b <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 830:	8b 45 ec             	mov    -0x14(%ebp),%eax
 833:	89 04 24             	mov    %eax,(%esp)
 836:	e8 ed fe ff ff       	call   728 <morecore>
 83b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 83e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 842:	75 07                	jne    84b <malloc+0xcb>
        return 0;
 844:	b8 00 00 00 00       	mov    $0x0,%eax
 849:	eb 13                	jmp    85e <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 851:	8b 45 f4             	mov    -0xc(%ebp),%eax
 854:	8b 00                	mov    (%eax),%eax
 856:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 859:	e9 70 ff ff ff       	jmp    7ce <malloc+0x4e>
}
 85e:	c9                   	leave  
 85f:	c3                   	ret    
