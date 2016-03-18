
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 05                	jne    11 <runcmd+0x11>
    exit();
       c:	e8 a4 0f 00 00       	call   fb5 <exit>
  
  switch(cmd->type){
      11:	8b 45 08             	mov    0x8(%ebp),%eax
      14:	8b 00                	mov    (%eax),%eax
      16:	83 f8 05             	cmp    $0x5,%eax
      19:	77 09                	ja     24 <runcmd+0x24>
      1b:	8b 04 85 40 15 00 00 	mov    0x1540(,%eax,4),%eax
      22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      24:	c7 04 24 14 15 00 00 	movl   $0x1514,(%esp)
      2b:	e8 7b 03 00 00       	call   3ab <panic>

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      30:	8b 45 08             	mov    0x8(%ebp),%eax
      33:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      36:	8b 45 f4             	mov    -0xc(%ebp),%eax
      39:	8b 40 04             	mov    0x4(%eax),%eax
      3c:	85 c0                	test   %eax,%eax
      3e:	75 05                	jne    45 <runcmd+0x45>
      exit();
      40:	e8 70 0f 00 00       	call   fb5 <exit>
    exec(ecmd->argv[0], ecmd->argv);
      45:	8b 45 f4             	mov    -0xc(%ebp),%eax
      48:	8d 50 04             	lea    0x4(%eax),%edx
      4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4e:	8b 40 04             	mov    0x4(%eax),%eax
      51:	89 54 24 04          	mov    %edx,0x4(%esp)
      55:	89 04 24             	mov    %eax,(%esp)
      58:	e8 90 0f 00 00       	call   fed <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
      60:	8b 40 04             	mov    0x4(%eax),%eax
      63:	89 44 24 08          	mov    %eax,0x8(%esp)
      67:	c7 44 24 04 1b 15 00 	movl   $0x151b,0x4(%esp)
      6e:	00 
      6f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      76:	e8 ca 10 00 00       	call   1145 <printf>
    break;
      7b:	e9 86 01 00 00       	jmp    206 <runcmd+0x206>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      80:	8b 45 08             	mov    0x8(%ebp),%eax
      83:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      86:	8b 45 f0             	mov    -0x10(%ebp),%eax
      89:	8b 40 14             	mov    0x14(%eax),%eax
      8c:	89 04 24             	mov    %eax,(%esp)
      8f:	e8 49 0f 00 00       	call   fdd <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      94:	8b 45 f0             	mov    -0x10(%ebp),%eax
      97:	8b 50 10             	mov    0x10(%eax),%edx
      9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
      9d:	8b 40 08             	mov    0x8(%eax),%eax
      a0:	89 54 24 04          	mov    %edx,0x4(%esp)
      a4:	89 04 24             	mov    %eax,(%esp)
      a7:	e8 49 0f 00 00       	call   ff5 <open>
      ac:	85 c0                	test   %eax,%eax
      ae:	79 23                	jns    d3 <runcmd+0xd3>
      printf(2, "open %s failed\n", rcmd->file);
      b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
      b3:	8b 40 08             	mov    0x8(%eax),%eax
      b6:	89 44 24 08          	mov    %eax,0x8(%esp)
      ba:	c7 44 24 04 2b 15 00 	movl   $0x152b,0x4(%esp)
      c1:	00 
      c2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      c9:	e8 77 10 00 00       	call   1145 <printf>
      exit();
      ce:	e8 e2 0e 00 00       	call   fb5 <exit>
    }
    runcmd(rcmd->cmd);
      d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
      d6:	8b 40 04             	mov    0x4(%eax),%eax
      d9:	89 04 24             	mov    %eax,(%esp)
      dc:	e8 1f ff ff ff       	call   0 <runcmd>
    break;
      e1:	e9 20 01 00 00       	jmp    206 <runcmd+0x206>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      e6:	8b 45 08             	mov    0x8(%ebp),%eax
      e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
      ec:	e8 e0 02 00 00       	call   3d1 <fork1>
      f1:	85 c0                	test   %eax,%eax
      f3:	75 0e                	jne    103 <runcmd+0x103>
     runcmd(lcmd->left);
      f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
      f8:	8b 40 04             	mov    0x4(%eax),%eax
      fb:	89 04 24             	mov    %eax,(%esp)
      fe:	e8 fd fe ff ff       	call   0 <runcmd>
    wait();
     103:	e8 b5 0e 00 00       	call   fbd <wait>
    runcmd(lcmd->right);
     108:	8b 45 ec             	mov    -0x14(%ebp),%eax
     10b:	8b 40 08             	mov    0x8(%eax),%eax
     10e:	89 04 24             	mov    %eax,(%esp)
     111:	e8 ea fe ff ff       	call   0 <runcmd>
    break;
     116:	e9 eb 00 00 00       	jmp    206 <runcmd+0x206>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     11b:	8b 45 08             	mov    0x8(%ebp),%eax
     11e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     121:	8d 45 dc             	lea    -0x24(%ebp),%eax
     124:	89 04 24             	mov    %eax,(%esp)
     127:	e8 99 0e 00 00       	call   fc5 <pipe>
     12c:	85 c0                	test   %eax,%eax
     12e:	79 0c                	jns    13c <runcmd+0x13c>
      panic("pipe");
     130:	c7 04 24 3b 15 00 00 	movl   $0x153b,(%esp)
     137:	e8 6f 02 00 00       	call   3ab <panic>
    if(fork1() == 0){
     13c:	e8 90 02 00 00       	call   3d1 <fork1>
     141:	85 c0                	test   %eax,%eax
     143:	75 3b                	jne    180 <runcmd+0x180>
      close(1);
     145:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     14c:	e8 8c 0e 00 00       	call   fdd <close>
      dup(p[1]);
     151:	8b 45 e0             	mov    -0x20(%ebp),%eax
     154:	89 04 24             	mov    %eax,(%esp)
     157:	e8 d1 0e 00 00       	call   102d <dup>
      close(p[0]);
     15c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     15f:	89 04 24             	mov    %eax,(%esp)
     162:	e8 76 0e 00 00       	call   fdd <close>
      close(p[1]);
     167:	8b 45 e0             	mov    -0x20(%ebp),%eax
     16a:	89 04 24             	mov    %eax,(%esp)
     16d:	e8 6b 0e 00 00       	call   fdd <close>
      runcmd(pcmd->left);
     172:	8b 45 e8             	mov    -0x18(%ebp),%eax
     175:	8b 40 04             	mov    0x4(%eax),%eax
     178:	89 04 24             	mov    %eax,(%esp)
     17b:	e8 80 fe ff ff       	call   0 <runcmd>
    }
    if(fork1() == 0){
     180:	e8 4c 02 00 00       	call   3d1 <fork1>
     185:	85 c0                	test   %eax,%eax
     187:	75 3b                	jne    1c4 <runcmd+0x1c4>
      close(0);
     189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     190:	e8 48 0e 00 00       	call   fdd <close>
      dup(p[0]);
     195:	8b 45 dc             	mov    -0x24(%ebp),%eax
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 8d 0e 00 00       	call   102d <dup>
      close(p[0]);
     1a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1a3:	89 04 24             	mov    %eax,(%esp)
     1a6:	e8 32 0e 00 00       	call   fdd <close>
      close(p[1]);
     1ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1ae:	89 04 24             	mov    %eax,(%esp)
     1b1:	e8 27 0e 00 00       	call   fdd <close>
      runcmd(pcmd->right);
     1b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1b9:	8b 40 08             	mov    0x8(%eax),%eax
     1bc:	89 04 24             	mov    %eax,(%esp)
     1bf:	e8 3c fe ff ff       	call   0 <runcmd>
    }
    close(p[0]);
     1c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1c7:	89 04 24             	mov    %eax,(%esp)
     1ca:	e8 0e 0e 00 00       	call   fdd <close>
    close(p[1]);
     1cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1d2:	89 04 24             	mov    %eax,(%esp)
     1d5:	e8 03 0e 00 00       	call   fdd <close>
    wait();
     1da:	e8 de 0d 00 00       	call   fbd <wait>
    wait();
     1df:	e8 d9 0d 00 00       	call   fbd <wait>
    break;
     1e4:	eb 20                	jmp    206 <runcmd+0x206>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     1e6:	8b 45 08             	mov    0x8(%ebp),%eax
     1e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     1ec:	e8 e0 01 00 00       	call   3d1 <fork1>
     1f1:	85 c0                	test   %eax,%eax
     1f3:	75 10                	jne    205 <runcmd+0x205>
      runcmd(bcmd->cmd);
     1f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     1f8:	8b 40 04             	mov    0x4(%eax),%eax
     1fb:	89 04 24             	mov    %eax,(%esp)
     1fe:	e8 fd fd ff ff       	call   0 <runcmd>
    break;
     203:	eb 00                	jmp    205 <runcmd+0x205>
     205:	90                   	nop
  }
  exit();
     206:	e8 aa 0d 00 00       	call   fb5 <exit>

0000020b <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     20b:	55                   	push   %ebp
     20c:	89 e5                	mov    %esp,%ebp
     20e:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     211:	c7 44 24 04 58 15 00 	movl   $0x1558,0x4(%esp)
     218:	00 
     219:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     220:	e8 20 0f 00 00       	call   1145 <printf>
  memset(buf, 0, nbuf);
     225:	8b 45 0c             	mov    0xc(%ebp),%eax
     228:	89 44 24 08          	mov    %eax,0x8(%esp)
     22c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     233:	00 
     234:	8b 45 08             	mov    0x8(%ebp),%eax
     237:	89 04 24             	mov    %eax,(%esp)
     23a:	e8 c9 0b 00 00       	call   e08 <memset>
  gets(buf, nbuf);
     23f:	8b 45 0c             	mov    0xc(%ebp),%eax
     242:	89 44 24 04          	mov    %eax,0x4(%esp)
     246:	8b 45 08             	mov    0x8(%ebp),%eax
     249:	89 04 24             	mov    %eax,(%esp)
     24c:	e8 0e 0c 00 00       	call   e5f <gets>
  if(buf[0] == 0) // EOF
     251:	8b 45 08             	mov    0x8(%ebp),%eax
     254:	0f b6 00             	movzbl (%eax),%eax
     257:	84 c0                	test   %al,%al
     259:	75 07                	jne    262 <getcmd+0x57>
    return -1;
     25b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     260:	eb 05                	jmp    267 <getcmd+0x5c>
  return 0;
     262:	b8 00 00 00 00       	mov    $0x0,%eax
}
     267:	c9                   	leave  
     268:	c3                   	ret    

00000269 <main>:
  }
}*/

int
main(void)
{
     269:	55                   	push   %ebp
     26a:	89 e5                	mov    %esp,%ebp
     26c:	83 e4 f0             	and    $0xfffffff0,%esp
     26f:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     272:	eb 15                	jmp    289 <main+0x20>
    if(fd >= 3){
     274:	83 7c 24 1c 02       	cmpl   $0x2,0x1c(%esp)
     279:	7e 0e                	jle    289 <main+0x20>
      close(fd);
     27b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     27f:	89 04 24             	mov    %eax,(%esp)
     282:	e8 56 0d 00 00       	call   fdd <close>
      break;
     287:	eb 1f                	jmp    2a8 <main+0x3f>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     289:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     290:	00 
     291:	c7 04 24 5b 15 00 00 	movl   $0x155b,(%esp)
     298:	e8 58 0d 00 00       	call   ff5 <open>
     29d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     2a1:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     2a6:	79 cc                	jns    274 <main+0xb>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2a8:	e9 dd 00 00 00       	jmp    38a <main+0x121>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2ad:	0f b6 05 c0 1a 00 00 	movzbl 0x1ac0,%eax
     2b4:	3c 63                	cmp    $0x63,%al
     2b6:	75 5c                	jne    314 <main+0xab>
     2b8:	0f b6 05 c1 1a 00 00 	movzbl 0x1ac1,%eax
     2bf:	3c 64                	cmp    $0x64,%al
     2c1:	75 51                	jne    314 <main+0xab>
     2c3:	0f b6 05 c2 1a 00 00 	movzbl 0x1ac2,%eax
     2ca:	3c 20                	cmp    $0x20,%al
     2cc:	75 46                	jne    314 <main+0xab>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     2ce:	c7 04 24 c0 1a 00 00 	movl   $0x1ac0,(%esp)
     2d5:	e8 07 0b 00 00       	call   de1 <strlen>
     2da:	83 e8 01             	sub    $0x1,%eax
     2dd:	c6 80 c0 1a 00 00 00 	movb   $0x0,0x1ac0(%eax)
      if(chdir(buf+3) < 0)
     2e4:	c7 04 24 c3 1a 00 00 	movl   $0x1ac3,(%esp)
     2eb:	e8 35 0d 00 00       	call   1025 <chdir>
     2f0:	85 c0                	test   %eax,%eax
     2f2:	79 1e                	jns    312 <main+0xa9>
        printf(2, "cannot cd %s\n", buf+3);
     2f4:	c7 44 24 08 c3 1a 00 	movl   $0x1ac3,0x8(%esp)
     2fb:	00 
     2fc:	c7 44 24 04 63 15 00 	movl   $0x1563,0x4(%esp)
     303:	00 
     304:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     30b:	e8 35 0e 00 00       	call   1145 <printf>
      continue;
     310:	eb 78                	jmp    38a <main+0x121>
     312:	eb 76                	jmp    38a <main+0x121>
    }
  else if(buf[0] == 'h' && buf[1] == 'i' && buf[2] == 's' && buf[3] == 't' && buf[4] == 'o' && buf[5] == 'r' && buf[6] == 'y'){
     314:	0f b6 05 c0 1a 00 00 	movzbl 0x1ac0,%eax
     31b:	3c 68                	cmp    $0x68,%al
     31d:	75 49                	jne    368 <main+0xff>
     31f:	0f b6 05 c1 1a 00 00 	movzbl 0x1ac1,%eax
     326:	3c 69                	cmp    $0x69,%al
     328:	75 3e                	jne    368 <main+0xff>
     32a:	0f b6 05 c2 1a 00 00 	movzbl 0x1ac2,%eax
     331:	3c 73                	cmp    $0x73,%al
     333:	75 33                	jne    368 <main+0xff>
     335:	0f b6 05 c3 1a 00 00 	movzbl 0x1ac3,%eax
     33c:	3c 74                	cmp    $0x74,%al
     33e:	75 28                	jne    368 <main+0xff>
     340:	0f b6 05 c4 1a 00 00 	movzbl 0x1ac4,%eax
     347:	3c 6f                	cmp    $0x6f,%al
     349:	75 1d                	jne    368 <main+0xff>
     34b:	0f b6 05 c5 1a 00 00 	movzbl 0x1ac5,%eax
     352:	3c 72                	cmp    $0x72,%al
     354:	75 12                	jne    368 <main+0xff>
     356:	0f b6 05 c6 1a 00 00 	movzbl 0x1ac6,%eax
     35d:	3c 79                	cmp    $0x79,%al
     35f:	75 07                	jne    368 <main+0xff>
      history();
     361:	e8 ef 0c 00 00       	call   1055 <history>

      continue;
     366:	eb 22                	jmp    38a <main+0x121>
    }
    if(fork1() == 0)
     368:	e8 64 00 00 00       	call   3d1 <fork1>
     36d:	85 c0                	test   %eax,%eax
     36f:	75 14                	jne    385 <main+0x11c>
      runcmd(parsecmd(buf));
     371:	c7 04 24 c0 1a 00 00 	movl   $0x1ac0,(%esp)
     378:	e8 c9 03 00 00       	call   746 <parsecmd>
     37d:	89 04 24             	mov    %eax,(%esp)
     380:	e8 7b fc ff ff       	call   0 <runcmd>
    wait();
     385:	e8 33 0c 00 00       	call   fbd <wait>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     38a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     391:	00 
     392:	c7 04 24 c0 1a 00 00 	movl   $0x1ac0,(%esp)
     399:	e8 6d fe ff ff       	call   20b <getcmd>
     39e:	85 c0                	test   %eax,%eax
     3a0:	0f 89 07 ff ff ff    	jns    2ad <main+0x44>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
     3a6:	e8 0a 0c 00 00       	call   fb5 <exit>

000003ab <panic>:
}

void
panic(char *s)
{
     3ab:	55                   	push   %ebp
     3ac:	89 e5                	mov    %esp,%ebp
     3ae:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     3b1:	8b 45 08             	mov    0x8(%ebp),%eax
     3b4:	89 44 24 08          	mov    %eax,0x8(%esp)
     3b8:	c7 44 24 04 71 15 00 	movl   $0x1571,0x4(%esp)
     3bf:	00 
     3c0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     3c7:	e8 79 0d 00 00       	call   1145 <printf>
  exit();
     3cc:	e8 e4 0b 00 00       	call   fb5 <exit>

000003d1 <fork1>:
}

int
fork1(void)
{
     3d1:	55                   	push   %ebp
     3d2:	89 e5                	mov    %esp,%ebp
     3d4:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     3d7:	e8 d1 0b 00 00       	call   fad <fork>
     3dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     3df:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     3e3:	75 0c                	jne    3f1 <fork1+0x20>
    panic("fork");
     3e5:	c7 04 24 75 15 00 00 	movl   $0x1575,(%esp)
     3ec:	e8 ba ff ff ff       	call   3ab <panic>
  return pid;
     3f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3f4:	c9                   	leave  
     3f5:	c3                   	ret    

000003f6 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     3f6:	55                   	push   %ebp
     3f7:	89 e5                	mov    %esp,%ebp
     3f9:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3fc:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     403:	e8 29 10 00 00       	call   1431 <malloc>
     408:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     40b:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     412:	00 
     413:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     41a:	00 
     41b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     41e:	89 04 24             	mov    %eax,(%esp)
     421:	e8 e2 09 00 00       	call   e08 <memset>
  cmd->type = EXEC;
     426:	8b 45 f4             	mov    -0xc(%ebp),%eax
     429:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     42f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     432:	c9                   	leave  
     433:	c3                   	ret    

00000434 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     434:	55                   	push   %ebp
     435:	89 e5                	mov    %esp,%ebp
     437:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     43a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     441:	e8 eb 0f 00 00       	call   1431 <malloc>
     446:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     449:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     450:	00 
     451:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     458:	00 
     459:	8b 45 f4             	mov    -0xc(%ebp),%eax
     45c:	89 04 24             	mov    %eax,(%esp)
     45f:	e8 a4 09 00 00       	call   e08 <memset>
  cmd->type = REDIR;
     464:	8b 45 f4             	mov    -0xc(%ebp),%eax
     467:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     46d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     470:	8b 55 08             	mov    0x8(%ebp),%edx
     473:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     476:	8b 45 f4             	mov    -0xc(%ebp),%eax
     479:	8b 55 0c             	mov    0xc(%ebp),%edx
     47c:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     47f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     482:	8b 55 10             	mov    0x10(%ebp),%edx
     485:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     488:	8b 45 f4             	mov    -0xc(%ebp),%eax
     48b:	8b 55 14             	mov    0x14(%ebp),%edx
     48e:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     491:	8b 45 f4             	mov    -0xc(%ebp),%eax
     494:	8b 55 18             	mov    0x18(%ebp),%edx
     497:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     49a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     49d:	c9                   	leave  
     49e:	c3                   	ret    

0000049f <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     49f:	55                   	push   %ebp
     4a0:	89 e5                	mov    %esp,%ebp
     4a2:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4a5:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     4ac:	e8 80 0f 00 00       	call   1431 <malloc>
     4b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4b4:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     4bb:	00 
     4bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     4c3:	00 
     4c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4c7:	89 04 24             	mov    %eax,(%esp)
     4ca:	e8 39 09 00 00       	call   e08 <memset>
  cmd->type = PIPE;
     4cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4d2:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     4d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4db:	8b 55 08             	mov    0x8(%ebp),%edx
     4de:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4e4:	8b 55 0c             	mov    0xc(%ebp),%edx
     4e7:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4ed:	c9                   	leave  
     4ee:	c3                   	ret    

000004ef <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     4ef:	55                   	push   %ebp
     4f0:	89 e5                	mov    %esp,%ebp
     4f2:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4f5:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     4fc:	e8 30 0f 00 00       	call   1431 <malloc>
     501:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     504:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     50b:	00 
     50c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     513:	00 
     514:	8b 45 f4             	mov    -0xc(%ebp),%eax
     517:	89 04 24             	mov    %eax,(%esp)
     51a:	e8 e9 08 00 00       	call   e08 <memset>
  cmd->type = LIST;
     51f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     522:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     528:	8b 45 f4             	mov    -0xc(%ebp),%eax
     52b:	8b 55 08             	mov    0x8(%ebp),%edx
     52e:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     531:	8b 45 f4             	mov    -0xc(%ebp),%eax
     534:	8b 55 0c             	mov    0xc(%ebp),%edx
     537:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     53a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     53d:	c9                   	leave  
     53e:	c3                   	ret    

0000053f <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     53f:	55                   	push   %ebp
     540:	89 e5                	mov    %esp,%ebp
     542:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     545:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     54c:	e8 e0 0e 00 00       	call   1431 <malloc>
     551:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     554:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     55b:	00 
     55c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     563:	00 
     564:	8b 45 f4             	mov    -0xc(%ebp),%eax
     567:	89 04 24             	mov    %eax,(%esp)
     56a:	e8 99 08 00 00       	call   e08 <memset>
  cmd->type = BACK;
     56f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     572:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     578:	8b 45 f4             	mov    -0xc(%ebp),%eax
     57b:	8b 55 08             	mov    0x8(%ebp),%edx
     57e:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     581:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     584:	c9                   	leave  
     585:	c3                   	ret    

00000586 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     586:	55                   	push   %ebp
     587:	89 e5                	mov    %esp,%ebp
     589:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     58c:	8b 45 08             	mov    0x8(%ebp),%eax
     58f:	8b 00                	mov    (%eax),%eax
     591:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     594:	eb 04                	jmp    59a <gettoken+0x14>
    s++;
     596:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     59a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     59d:	3b 45 0c             	cmp    0xc(%ebp),%eax
     5a0:	73 1d                	jae    5bf <gettoken+0x39>
     5a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5a5:	0f b6 00             	movzbl (%eax),%eax
     5a8:	0f be c0             	movsbl %al,%eax
     5ab:	89 44 24 04          	mov    %eax,0x4(%esp)
     5af:	c7 04 24 8c 1a 00 00 	movl   $0x1a8c,(%esp)
     5b6:	e8 71 08 00 00       	call   e2c <strchr>
     5bb:	85 c0                	test   %eax,%eax
     5bd:	75 d7                	jne    596 <gettoken+0x10>
    s++;
  if(q)
     5bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     5c3:	74 08                	je     5cd <gettoken+0x47>
    *q = s;
     5c5:	8b 45 10             	mov    0x10(%ebp),%eax
     5c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
     5cb:	89 10                	mov    %edx,(%eax)
  ret = *s;
     5cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5d0:	0f b6 00             	movzbl (%eax),%eax
     5d3:	0f be c0             	movsbl %al,%eax
     5d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     5d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5dc:	0f b6 00             	movzbl (%eax),%eax
     5df:	0f be c0             	movsbl %al,%eax
     5e2:	83 f8 29             	cmp    $0x29,%eax
     5e5:	7f 14                	jg     5fb <gettoken+0x75>
     5e7:	83 f8 28             	cmp    $0x28,%eax
     5ea:	7d 28                	jge    614 <gettoken+0x8e>
     5ec:	85 c0                	test   %eax,%eax
     5ee:	0f 84 94 00 00 00    	je     688 <gettoken+0x102>
     5f4:	83 f8 26             	cmp    $0x26,%eax
     5f7:	74 1b                	je     614 <gettoken+0x8e>
     5f9:	eb 3c                	jmp    637 <gettoken+0xb1>
     5fb:	83 f8 3e             	cmp    $0x3e,%eax
     5fe:	74 1a                	je     61a <gettoken+0x94>
     600:	83 f8 3e             	cmp    $0x3e,%eax
     603:	7f 0a                	jg     60f <gettoken+0x89>
     605:	83 e8 3b             	sub    $0x3b,%eax
     608:	83 f8 01             	cmp    $0x1,%eax
     60b:	77 2a                	ja     637 <gettoken+0xb1>
     60d:	eb 05                	jmp    614 <gettoken+0x8e>
     60f:	83 f8 7c             	cmp    $0x7c,%eax
     612:	75 23                	jne    637 <gettoken+0xb1>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     614:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     618:	eb 6f                	jmp    689 <gettoken+0x103>
  case '>':
    s++;
     61a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     61e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     621:	0f b6 00             	movzbl (%eax),%eax
     624:	3c 3e                	cmp    $0x3e,%al
     626:	75 0d                	jne    635 <gettoken+0xaf>
      ret = '+';
     628:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     62f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     633:	eb 54                	jmp    689 <gettoken+0x103>
     635:	eb 52                	jmp    689 <gettoken+0x103>
  default:
    ret = 'a';
     637:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     63e:	eb 04                	jmp    644 <gettoken+0xbe>
      s++;
     640:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     644:	8b 45 f4             	mov    -0xc(%ebp),%eax
     647:	3b 45 0c             	cmp    0xc(%ebp),%eax
     64a:	73 3a                	jae    686 <gettoken+0x100>
     64c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     64f:	0f b6 00             	movzbl (%eax),%eax
     652:	0f be c0             	movsbl %al,%eax
     655:	89 44 24 04          	mov    %eax,0x4(%esp)
     659:	c7 04 24 8c 1a 00 00 	movl   $0x1a8c,(%esp)
     660:	e8 c7 07 00 00       	call   e2c <strchr>
     665:	85 c0                	test   %eax,%eax
     667:	75 1d                	jne    686 <gettoken+0x100>
     669:	8b 45 f4             	mov    -0xc(%ebp),%eax
     66c:	0f b6 00             	movzbl (%eax),%eax
     66f:	0f be c0             	movsbl %al,%eax
     672:	89 44 24 04          	mov    %eax,0x4(%esp)
     676:	c7 04 24 92 1a 00 00 	movl   $0x1a92,(%esp)
     67d:	e8 aa 07 00 00       	call   e2c <strchr>
     682:	85 c0                	test   %eax,%eax
     684:	74 ba                	je     640 <gettoken+0xba>
      s++;
    break;
     686:	eb 01                	jmp    689 <gettoken+0x103>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     688:	90                   	nop
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     689:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     68d:	74 0a                	je     699 <gettoken+0x113>
    *eq = s;
     68f:	8b 45 14             	mov    0x14(%ebp),%eax
     692:	8b 55 f4             	mov    -0xc(%ebp),%edx
     695:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     697:	eb 06                	jmp    69f <gettoken+0x119>
     699:	eb 04                	jmp    69f <gettoken+0x119>
    s++;
     69b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     69f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6a2:	3b 45 0c             	cmp    0xc(%ebp),%eax
     6a5:	73 1d                	jae    6c4 <gettoken+0x13e>
     6a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6aa:	0f b6 00             	movzbl (%eax),%eax
     6ad:	0f be c0             	movsbl %al,%eax
     6b0:	89 44 24 04          	mov    %eax,0x4(%esp)
     6b4:	c7 04 24 8c 1a 00 00 	movl   $0x1a8c,(%esp)
     6bb:	e8 6c 07 00 00       	call   e2c <strchr>
     6c0:	85 c0                	test   %eax,%eax
     6c2:	75 d7                	jne    69b <gettoken+0x115>
    s++;
  *ps = s;
     6c4:	8b 45 08             	mov    0x8(%ebp),%eax
     6c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6ca:	89 10                	mov    %edx,(%eax)
  return ret;
     6cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     6cf:	c9                   	leave  
     6d0:	c3                   	ret    

000006d1 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     6d1:	55                   	push   %ebp
     6d2:	89 e5                	mov    %esp,%ebp
     6d4:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     6d7:	8b 45 08             	mov    0x8(%ebp),%eax
     6da:	8b 00                	mov    (%eax),%eax
     6dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     6df:	eb 04                	jmp    6e5 <peek+0x14>
    s++;
     6e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     6e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6e8:	3b 45 0c             	cmp    0xc(%ebp),%eax
     6eb:	73 1d                	jae    70a <peek+0x39>
     6ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6f0:	0f b6 00             	movzbl (%eax),%eax
     6f3:	0f be c0             	movsbl %al,%eax
     6f6:	89 44 24 04          	mov    %eax,0x4(%esp)
     6fa:	c7 04 24 8c 1a 00 00 	movl   $0x1a8c,(%esp)
     701:	e8 26 07 00 00       	call   e2c <strchr>
     706:	85 c0                	test   %eax,%eax
     708:	75 d7                	jne    6e1 <peek+0x10>
    s++;
  *ps = s;
     70a:	8b 45 08             	mov    0x8(%ebp),%eax
     70d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     710:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     712:	8b 45 f4             	mov    -0xc(%ebp),%eax
     715:	0f b6 00             	movzbl (%eax),%eax
     718:	84 c0                	test   %al,%al
     71a:	74 23                	je     73f <peek+0x6e>
     71c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     71f:	0f b6 00             	movzbl (%eax),%eax
     722:	0f be c0             	movsbl %al,%eax
     725:	89 44 24 04          	mov    %eax,0x4(%esp)
     729:	8b 45 10             	mov    0x10(%ebp),%eax
     72c:	89 04 24             	mov    %eax,(%esp)
     72f:	e8 f8 06 00 00       	call   e2c <strchr>
     734:	85 c0                	test   %eax,%eax
     736:	74 07                	je     73f <peek+0x6e>
     738:	b8 01 00 00 00       	mov    $0x1,%eax
     73d:	eb 05                	jmp    744 <peek+0x73>
     73f:	b8 00 00 00 00       	mov    $0x0,%eax
}
     744:	c9                   	leave  
     745:	c3                   	ret    

00000746 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     746:	55                   	push   %ebp
     747:	89 e5                	mov    %esp,%ebp
     749:	53                   	push   %ebx
     74a:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     74d:	8b 5d 08             	mov    0x8(%ebp),%ebx
     750:	8b 45 08             	mov    0x8(%ebp),%eax
     753:	89 04 24             	mov    %eax,(%esp)
     756:	e8 86 06 00 00       	call   de1 <strlen>
     75b:	01 d8                	add    %ebx,%eax
     75d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     760:	8b 45 f4             	mov    -0xc(%ebp),%eax
     763:	89 44 24 04          	mov    %eax,0x4(%esp)
     767:	8d 45 08             	lea    0x8(%ebp),%eax
     76a:	89 04 24             	mov    %eax,(%esp)
     76d:	e8 60 00 00 00       	call   7d2 <parseline>
     772:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     775:	c7 44 24 08 7a 15 00 	movl   $0x157a,0x8(%esp)
     77c:	00 
     77d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     780:	89 44 24 04          	mov    %eax,0x4(%esp)
     784:	8d 45 08             	lea    0x8(%ebp),%eax
     787:	89 04 24             	mov    %eax,(%esp)
     78a:	e8 42 ff ff ff       	call   6d1 <peek>
  if(s != es){
     78f:	8b 45 08             	mov    0x8(%ebp),%eax
     792:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     795:	74 27                	je     7be <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     797:	8b 45 08             	mov    0x8(%ebp),%eax
     79a:	89 44 24 08          	mov    %eax,0x8(%esp)
     79e:	c7 44 24 04 7b 15 00 	movl   $0x157b,0x4(%esp)
     7a5:	00 
     7a6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     7ad:	e8 93 09 00 00       	call   1145 <printf>
    panic("syntax");
     7b2:	c7 04 24 8a 15 00 00 	movl   $0x158a,(%esp)
     7b9:	e8 ed fb ff ff       	call   3ab <panic>
  }
  nulterminate(cmd);
     7be:	8b 45 f0             	mov    -0x10(%ebp),%eax
     7c1:	89 04 24             	mov    %eax,(%esp)
     7c4:	e8 a3 04 00 00       	call   c6c <nulterminate>
  return cmd;
     7c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     7cc:	83 c4 24             	add    $0x24,%esp
     7cf:	5b                   	pop    %ebx
     7d0:	5d                   	pop    %ebp
     7d1:	c3                   	ret    

000007d2 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     7d2:	55                   	push   %ebp
     7d3:	89 e5                	mov    %esp,%ebp
     7d5:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     7d8:	8b 45 0c             	mov    0xc(%ebp),%eax
     7db:	89 44 24 04          	mov    %eax,0x4(%esp)
     7df:	8b 45 08             	mov    0x8(%ebp),%eax
     7e2:	89 04 24             	mov    %eax,(%esp)
     7e5:	e8 bc 00 00 00       	call   8a6 <parsepipe>
     7ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     7ed:	eb 30                	jmp    81f <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     7ef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     7f6:	00 
     7f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     7fe:	00 
     7ff:	8b 45 0c             	mov    0xc(%ebp),%eax
     802:	89 44 24 04          	mov    %eax,0x4(%esp)
     806:	8b 45 08             	mov    0x8(%ebp),%eax
     809:	89 04 24             	mov    %eax,(%esp)
     80c:	e8 75 fd ff ff       	call   586 <gettoken>
    cmd = backcmd(cmd);
     811:	8b 45 f4             	mov    -0xc(%ebp),%eax
     814:	89 04 24             	mov    %eax,(%esp)
     817:	e8 23 fd ff ff       	call   53f <backcmd>
     81c:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     81f:	c7 44 24 08 91 15 00 	movl   $0x1591,0x8(%esp)
     826:	00 
     827:	8b 45 0c             	mov    0xc(%ebp),%eax
     82a:	89 44 24 04          	mov    %eax,0x4(%esp)
     82e:	8b 45 08             	mov    0x8(%ebp),%eax
     831:	89 04 24             	mov    %eax,(%esp)
     834:	e8 98 fe ff ff       	call   6d1 <peek>
     839:	85 c0                	test   %eax,%eax
     83b:	75 b2                	jne    7ef <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     83d:	c7 44 24 08 93 15 00 	movl   $0x1593,0x8(%esp)
     844:	00 
     845:	8b 45 0c             	mov    0xc(%ebp),%eax
     848:	89 44 24 04          	mov    %eax,0x4(%esp)
     84c:	8b 45 08             	mov    0x8(%ebp),%eax
     84f:	89 04 24             	mov    %eax,(%esp)
     852:	e8 7a fe ff ff       	call   6d1 <peek>
     857:	85 c0                	test   %eax,%eax
     859:	74 46                	je     8a1 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     85b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     862:	00 
     863:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     86a:	00 
     86b:	8b 45 0c             	mov    0xc(%ebp),%eax
     86e:	89 44 24 04          	mov    %eax,0x4(%esp)
     872:	8b 45 08             	mov    0x8(%ebp),%eax
     875:	89 04 24             	mov    %eax,(%esp)
     878:	e8 09 fd ff ff       	call   586 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     87d:	8b 45 0c             	mov    0xc(%ebp),%eax
     880:	89 44 24 04          	mov    %eax,0x4(%esp)
     884:	8b 45 08             	mov    0x8(%ebp),%eax
     887:	89 04 24             	mov    %eax,(%esp)
     88a:	e8 43 ff ff ff       	call   7d2 <parseline>
     88f:	89 44 24 04          	mov    %eax,0x4(%esp)
     893:	8b 45 f4             	mov    -0xc(%ebp),%eax
     896:	89 04 24             	mov    %eax,(%esp)
     899:	e8 51 fc ff ff       	call   4ef <listcmd>
     89e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8a4:	c9                   	leave  
     8a5:	c3                   	ret    

000008a6 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     8a6:	55                   	push   %ebp
     8a7:	89 e5                	mov    %esp,%ebp
     8a9:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     8ac:	8b 45 0c             	mov    0xc(%ebp),%eax
     8af:	89 44 24 04          	mov    %eax,0x4(%esp)
     8b3:	8b 45 08             	mov    0x8(%ebp),%eax
     8b6:	89 04 24             	mov    %eax,(%esp)
     8b9:	e8 68 02 00 00       	call   b26 <parseexec>
     8be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     8c1:	c7 44 24 08 95 15 00 	movl   $0x1595,0x8(%esp)
     8c8:	00 
     8c9:	8b 45 0c             	mov    0xc(%ebp),%eax
     8cc:	89 44 24 04          	mov    %eax,0x4(%esp)
     8d0:	8b 45 08             	mov    0x8(%ebp),%eax
     8d3:	89 04 24             	mov    %eax,(%esp)
     8d6:	e8 f6 fd ff ff       	call   6d1 <peek>
     8db:	85 c0                	test   %eax,%eax
     8dd:	74 46                	je     925 <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     8df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8e6:	00 
     8e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8ee:	00 
     8ef:	8b 45 0c             	mov    0xc(%ebp),%eax
     8f2:	89 44 24 04          	mov    %eax,0x4(%esp)
     8f6:	8b 45 08             	mov    0x8(%ebp),%eax
     8f9:	89 04 24             	mov    %eax,(%esp)
     8fc:	e8 85 fc ff ff       	call   586 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     901:	8b 45 0c             	mov    0xc(%ebp),%eax
     904:	89 44 24 04          	mov    %eax,0x4(%esp)
     908:	8b 45 08             	mov    0x8(%ebp),%eax
     90b:	89 04 24             	mov    %eax,(%esp)
     90e:	e8 93 ff ff ff       	call   8a6 <parsepipe>
     913:	89 44 24 04          	mov    %eax,0x4(%esp)
     917:	8b 45 f4             	mov    -0xc(%ebp),%eax
     91a:	89 04 24             	mov    %eax,(%esp)
     91d:	e8 7d fb ff ff       	call   49f <pipecmd>
     922:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     925:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     928:	c9                   	leave  
     929:	c3                   	ret    

0000092a <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     92a:	55                   	push   %ebp
     92b:	89 e5                	mov    %esp,%ebp
     92d:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     930:	e9 f6 00 00 00       	jmp    a2b <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     935:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     93c:	00 
     93d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     944:	00 
     945:	8b 45 10             	mov    0x10(%ebp),%eax
     948:	89 44 24 04          	mov    %eax,0x4(%esp)
     94c:	8b 45 0c             	mov    0xc(%ebp),%eax
     94f:	89 04 24             	mov    %eax,(%esp)
     952:	e8 2f fc ff ff       	call   586 <gettoken>
     957:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     95a:	8d 45 ec             	lea    -0x14(%ebp),%eax
     95d:	89 44 24 0c          	mov    %eax,0xc(%esp)
     961:	8d 45 f0             	lea    -0x10(%ebp),%eax
     964:	89 44 24 08          	mov    %eax,0x8(%esp)
     968:	8b 45 10             	mov    0x10(%ebp),%eax
     96b:	89 44 24 04          	mov    %eax,0x4(%esp)
     96f:	8b 45 0c             	mov    0xc(%ebp),%eax
     972:	89 04 24             	mov    %eax,(%esp)
     975:	e8 0c fc ff ff       	call   586 <gettoken>
     97a:	83 f8 61             	cmp    $0x61,%eax
     97d:	74 0c                	je     98b <parseredirs+0x61>
      panic("missing file for redirection");
     97f:	c7 04 24 97 15 00 00 	movl   $0x1597,(%esp)
     986:	e8 20 fa ff ff       	call   3ab <panic>
    switch(tok){
     98b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     98e:	83 f8 3c             	cmp    $0x3c,%eax
     991:	74 0f                	je     9a2 <parseredirs+0x78>
     993:	83 f8 3e             	cmp    $0x3e,%eax
     996:	74 38                	je     9d0 <parseredirs+0xa6>
     998:	83 f8 2b             	cmp    $0x2b,%eax
     99b:	74 61                	je     9fe <parseredirs+0xd4>
     99d:	e9 89 00 00 00       	jmp    a2b <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     9a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9a8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     9af:	00 
     9b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     9b7:	00 
     9b8:	89 54 24 08          	mov    %edx,0x8(%esp)
     9bc:	89 44 24 04          	mov    %eax,0x4(%esp)
     9c0:	8b 45 08             	mov    0x8(%ebp),%eax
     9c3:	89 04 24             	mov    %eax,(%esp)
     9c6:	e8 69 fa ff ff       	call   434 <redircmd>
     9cb:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9ce:	eb 5b                	jmp    a2b <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9d6:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     9dd:	00 
     9de:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     9e5:	00 
     9e6:	89 54 24 08          	mov    %edx,0x8(%esp)
     9ea:	89 44 24 04          	mov    %eax,0x4(%esp)
     9ee:	8b 45 08             	mov    0x8(%ebp),%eax
     9f1:	89 04 24             	mov    %eax,(%esp)
     9f4:	e8 3b fa ff ff       	call   434 <redircmd>
     9f9:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9fc:	eb 2d                	jmp    a2b <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9fe:	8b 55 ec             	mov    -0x14(%ebp),%edx
     a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a04:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     a0b:	00 
     a0c:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     a13:	00 
     a14:	89 54 24 08          	mov    %edx,0x8(%esp)
     a18:	89 44 24 04          	mov    %eax,0x4(%esp)
     a1c:	8b 45 08             	mov    0x8(%ebp),%eax
     a1f:	89 04 24             	mov    %eax,(%esp)
     a22:	e8 0d fa ff ff       	call   434 <redircmd>
     a27:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     a2a:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     a2b:	c7 44 24 08 b4 15 00 	movl   $0x15b4,0x8(%esp)
     a32:	00 
     a33:	8b 45 10             	mov    0x10(%ebp),%eax
     a36:	89 44 24 04          	mov    %eax,0x4(%esp)
     a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
     a3d:	89 04 24             	mov    %eax,(%esp)
     a40:	e8 8c fc ff ff       	call   6d1 <peek>
     a45:	85 c0                	test   %eax,%eax
     a47:	0f 85 e8 fe ff ff    	jne    935 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     a4d:	8b 45 08             	mov    0x8(%ebp),%eax
}
     a50:	c9                   	leave  
     a51:	c3                   	ret    

00000a52 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     a52:	55                   	push   %ebp
     a53:	89 e5                	mov    %esp,%ebp
     a55:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     a58:	c7 44 24 08 b7 15 00 	movl   $0x15b7,0x8(%esp)
     a5f:	00 
     a60:	8b 45 0c             	mov    0xc(%ebp),%eax
     a63:	89 44 24 04          	mov    %eax,0x4(%esp)
     a67:	8b 45 08             	mov    0x8(%ebp),%eax
     a6a:	89 04 24             	mov    %eax,(%esp)
     a6d:	e8 5f fc ff ff       	call   6d1 <peek>
     a72:	85 c0                	test   %eax,%eax
     a74:	75 0c                	jne    a82 <parseblock+0x30>
    panic("parseblock");
     a76:	c7 04 24 b9 15 00 00 	movl   $0x15b9,(%esp)
     a7d:	e8 29 f9 ff ff       	call   3ab <panic>
  gettoken(ps, es, 0, 0);
     a82:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a89:	00 
     a8a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     a91:	00 
     a92:	8b 45 0c             	mov    0xc(%ebp),%eax
     a95:	89 44 24 04          	mov    %eax,0x4(%esp)
     a99:	8b 45 08             	mov    0x8(%ebp),%eax
     a9c:	89 04 24             	mov    %eax,(%esp)
     a9f:	e8 e2 fa ff ff       	call   586 <gettoken>
  cmd = parseline(ps, es);
     aa4:	8b 45 0c             	mov    0xc(%ebp),%eax
     aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
     aab:	8b 45 08             	mov    0x8(%ebp),%eax
     aae:	89 04 24             	mov    %eax,(%esp)
     ab1:	e8 1c fd ff ff       	call   7d2 <parseline>
     ab6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     ab9:	c7 44 24 08 c4 15 00 	movl   $0x15c4,0x8(%esp)
     ac0:	00 
     ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
     ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
     ac8:	8b 45 08             	mov    0x8(%ebp),%eax
     acb:	89 04 24             	mov    %eax,(%esp)
     ace:	e8 fe fb ff ff       	call   6d1 <peek>
     ad3:	85 c0                	test   %eax,%eax
     ad5:	75 0c                	jne    ae3 <parseblock+0x91>
    panic("syntax - missing )");
     ad7:	c7 04 24 c6 15 00 00 	movl   $0x15c6,(%esp)
     ade:	e8 c8 f8 ff ff       	call   3ab <panic>
  gettoken(ps, es, 0, 0);
     ae3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     aea:	00 
     aeb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     af2:	00 
     af3:	8b 45 0c             	mov    0xc(%ebp),%eax
     af6:	89 44 24 04          	mov    %eax,0x4(%esp)
     afa:	8b 45 08             	mov    0x8(%ebp),%eax
     afd:	89 04 24             	mov    %eax,(%esp)
     b00:	e8 81 fa ff ff       	call   586 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     b05:	8b 45 0c             	mov    0xc(%ebp),%eax
     b08:	89 44 24 08          	mov    %eax,0x8(%esp)
     b0c:	8b 45 08             	mov    0x8(%ebp),%eax
     b0f:	89 44 24 04          	mov    %eax,0x4(%esp)
     b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b16:	89 04 24             	mov    %eax,(%esp)
     b19:	e8 0c fe ff ff       	call   92a <parseredirs>
     b1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     b24:	c9                   	leave  
     b25:	c3                   	ret    

00000b26 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     b26:	55                   	push   %ebp
     b27:	89 e5                	mov    %esp,%ebp
     b29:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     b2c:	c7 44 24 08 b7 15 00 	movl   $0x15b7,0x8(%esp)
     b33:	00 
     b34:	8b 45 0c             	mov    0xc(%ebp),%eax
     b37:	89 44 24 04          	mov    %eax,0x4(%esp)
     b3b:	8b 45 08             	mov    0x8(%ebp),%eax
     b3e:	89 04 24             	mov    %eax,(%esp)
     b41:	e8 8b fb ff ff       	call   6d1 <peek>
     b46:	85 c0                	test   %eax,%eax
     b48:	74 17                	je     b61 <parseexec+0x3b>
    return parseblock(ps, es);
     b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
     b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
     b51:	8b 45 08             	mov    0x8(%ebp),%eax
     b54:	89 04 24             	mov    %eax,(%esp)
     b57:	e8 f6 fe ff ff       	call   a52 <parseblock>
     b5c:	e9 09 01 00 00       	jmp    c6a <parseexec+0x144>

  ret = execcmd();
     b61:	e8 90 f8 ff ff       	call   3f6 <execcmd>
     b66:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b6c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     b6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     b76:	8b 45 0c             	mov    0xc(%ebp),%eax
     b79:	89 44 24 08          	mov    %eax,0x8(%esp)
     b7d:	8b 45 08             	mov    0x8(%ebp),%eax
     b80:	89 44 24 04          	mov    %eax,0x4(%esp)
     b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b87:	89 04 24             	mov    %eax,(%esp)
     b8a:	e8 9b fd ff ff       	call   92a <parseredirs>
     b8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     b92:	e9 8f 00 00 00       	jmp    c26 <parseexec+0x100>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     b97:	8d 45 e0             	lea    -0x20(%ebp),%eax
     b9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
     b9e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     ba1:	89 44 24 08          	mov    %eax,0x8(%esp)
     ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
     ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
     bac:	8b 45 08             	mov    0x8(%ebp),%eax
     baf:	89 04 24             	mov    %eax,(%esp)
     bb2:	e8 cf f9 ff ff       	call   586 <gettoken>
     bb7:	89 45 e8             	mov    %eax,-0x18(%ebp)
     bba:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     bbe:	75 05                	jne    bc5 <parseexec+0x9f>
      break;
     bc0:	e9 83 00 00 00       	jmp    c48 <parseexec+0x122>
    if(tok != 'a')
     bc5:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     bc9:	74 0c                	je     bd7 <parseexec+0xb1>
      panic("syntax");
     bcb:	c7 04 24 8a 15 00 00 	movl   $0x158a,(%esp)
     bd2:	e8 d4 f7 ff ff       	call   3ab <panic>
    cmd->argv[argc] = q;
     bd7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     bda:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
     be0:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     be4:	8b 55 e0             	mov    -0x20(%ebp),%edx
     be7:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bea:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     bed:	83 c1 08             	add    $0x8,%ecx
     bf0:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     bf4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     bf8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     bfc:	7e 0c                	jle    c0a <parseexec+0xe4>
      panic("too many args");
     bfe:	c7 04 24 d9 15 00 00 	movl   $0x15d9,(%esp)
     c05:	e8 a1 f7 ff ff       	call   3ab <panic>
    ret = parseredirs(ret, ps, es);
     c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
     c0d:	89 44 24 08          	mov    %eax,0x8(%esp)
     c11:	8b 45 08             	mov    0x8(%ebp),%eax
     c14:	89 44 24 04          	mov    %eax,0x4(%esp)
     c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c1b:	89 04 24             	mov    %eax,(%esp)
     c1e:	e8 07 fd ff ff       	call   92a <parseredirs>
     c23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     c26:	c7 44 24 08 e7 15 00 	movl   $0x15e7,0x8(%esp)
     c2d:	00 
     c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
     c31:	89 44 24 04          	mov    %eax,0x4(%esp)
     c35:	8b 45 08             	mov    0x8(%ebp),%eax
     c38:	89 04 24             	mov    %eax,(%esp)
     c3b:	e8 91 fa ff ff       	call   6d1 <peek>
     c40:	85 c0                	test   %eax,%eax
     c42:	0f 84 4f ff ff ff    	je     b97 <parseexec+0x71>
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     c48:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c4e:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     c55:	00 
  cmd->eargv[argc] = 0;
     c56:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c59:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c5c:	83 c2 08             	add    $0x8,%edx
     c5f:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     c66:	00 
  return ret;
     c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     c6a:	c9                   	leave  
     c6b:	c3                   	ret    

00000c6c <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     c6c:	55                   	push   %ebp
     c6d:	89 e5                	mov    %esp,%ebp
     c6f:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     c72:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     c76:	75 0a                	jne    c82 <nulterminate+0x16>
    return 0;
     c78:	b8 00 00 00 00       	mov    $0x0,%eax
     c7d:	e9 c9 00 00 00       	jmp    d4b <nulterminate+0xdf>
  
  switch(cmd->type){
     c82:	8b 45 08             	mov    0x8(%ebp),%eax
     c85:	8b 00                	mov    (%eax),%eax
     c87:	83 f8 05             	cmp    $0x5,%eax
     c8a:	0f 87 b8 00 00 00    	ja     d48 <nulterminate+0xdc>
     c90:	8b 04 85 ec 15 00 00 	mov    0x15ec(,%eax,4),%eax
     c97:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     c99:	8b 45 08             	mov    0x8(%ebp),%eax
     c9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     c9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     ca6:	eb 14                	jmp    cbc <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
     cab:	8b 55 f4             	mov    -0xc(%ebp),%edx
     cae:	83 c2 08             	add    $0x8,%edx
     cb1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     cb5:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     cb8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
     cbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
     cc2:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     cc6:	85 c0                	test   %eax,%eax
     cc8:	75 de                	jne    ca8 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     cca:	eb 7c                	jmp    d48 <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     ccc:	8b 45 08             	mov    0x8(%ebp),%eax
     ccf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     cd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
     cd5:	8b 40 04             	mov    0x4(%eax),%eax
     cd8:	89 04 24             	mov    %eax,(%esp)
     cdb:	e8 8c ff ff ff       	call   c6c <nulterminate>
    *rcmd->efile = 0;
     ce0:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ce3:	8b 40 0c             	mov    0xc(%eax),%eax
     ce6:	c6 00 00             	movb   $0x0,(%eax)
    break;
     ce9:	eb 5d                	jmp    d48 <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     ceb:	8b 45 08             	mov    0x8(%ebp),%eax
     cee:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     cf1:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cf4:	8b 40 04             	mov    0x4(%eax),%eax
     cf7:	89 04 24             	mov    %eax,(%esp)
     cfa:	e8 6d ff ff ff       	call   c6c <nulterminate>
    nulterminate(pcmd->right);
     cff:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d02:	8b 40 08             	mov    0x8(%eax),%eax
     d05:	89 04 24             	mov    %eax,(%esp)
     d08:	e8 5f ff ff ff       	call   c6c <nulterminate>
    break;
     d0d:	eb 39                	jmp    d48 <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     d0f:	8b 45 08             	mov    0x8(%ebp),%eax
     d12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     d15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d18:	8b 40 04             	mov    0x4(%eax),%eax
     d1b:	89 04 24             	mov    %eax,(%esp)
     d1e:	e8 49 ff ff ff       	call   c6c <nulterminate>
    nulterminate(lcmd->right);
     d23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d26:	8b 40 08             	mov    0x8(%eax),%eax
     d29:	89 04 24             	mov    %eax,(%esp)
     d2c:	e8 3b ff ff ff       	call   c6c <nulterminate>
    break;
     d31:	eb 15                	jmp    d48 <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     d33:	8b 45 08             	mov    0x8(%ebp),%eax
     d36:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     d39:	8b 45 e0             	mov    -0x20(%ebp),%eax
     d3c:	8b 40 04             	mov    0x4(%eax),%eax
     d3f:	89 04 24             	mov    %eax,(%esp)
     d42:	e8 25 ff ff ff       	call   c6c <nulterminate>
    break;
     d47:	90                   	nop
  }
  return cmd;
     d48:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d4b:	c9                   	leave  
     d4c:	c3                   	ret    

00000d4d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     d4d:	55                   	push   %ebp
     d4e:	89 e5                	mov    %esp,%ebp
     d50:	57                   	push   %edi
     d51:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     d52:	8b 4d 08             	mov    0x8(%ebp),%ecx
     d55:	8b 55 10             	mov    0x10(%ebp),%edx
     d58:	8b 45 0c             	mov    0xc(%ebp),%eax
     d5b:	89 cb                	mov    %ecx,%ebx
     d5d:	89 df                	mov    %ebx,%edi
     d5f:	89 d1                	mov    %edx,%ecx
     d61:	fc                   	cld    
     d62:	f3 aa                	rep stos %al,%es:(%edi)
     d64:	89 ca                	mov    %ecx,%edx
     d66:	89 fb                	mov    %edi,%ebx
     d68:	89 5d 08             	mov    %ebx,0x8(%ebp)
     d6b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     d6e:	5b                   	pop    %ebx
     d6f:	5f                   	pop    %edi
     d70:	5d                   	pop    %ebp
     d71:	c3                   	ret    

00000d72 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     d72:	55                   	push   %ebp
     d73:	89 e5                	mov    %esp,%ebp
     d75:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     d78:	8b 45 08             	mov    0x8(%ebp),%eax
     d7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     d7e:	90                   	nop
     d7f:	8b 45 08             	mov    0x8(%ebp),%eax
     d82:	8d 50 01             	lea    0x1(%eax),%edx
     d85:	89 55 08             	mov    %edx,0x8(%ebp)
     d88:	8b 55 0c             	mov    0xc(%ebp),%edx
     d8b:	8d 4a 01             	lea    0x1(%edx),%ecx
     d8e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     d91:	0f b6 12             	movzbl (%edx),%edx
     d94:	88 10                	mov    %dl,(%eax)
     d96:	0f b6 00             	movzbl (%eax),%eax
     d99:	84 c0                	test   %al,%al
     d9b:	75 e2                	jne    d7f <strcpy+0xd>
    ;
  return os;
     d9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     da0:	c9                   	leave  
     da1:	c3                   	ret    

00000da2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     da2:	55                   	push   %ebp
     da3:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     da5:	eb 08                	jmp    daf <strcmp+0xd>
    p++, q++;
     da7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     dab:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     daf:	8b 45 08             	mov    0x8(%ebp),%eax
     db2:	0f b6 00             	movzbl (%eax),%eax
     db5:	84 c0                	test   %al,%al
     db7:	74 10                	je     dc9 <strcmp+0x27>
     db9:	8b 45 08             	mov    0x8(%ebp),%eax
     dbc:	0f b6 10             	movzbl (%eax),%edx
     dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
     dc2:	0f b6 00             	movzbl (%eax),%eax
     dc5:	38 c2                	cmp    %al,%dl
     dc7:	74 de                	je     da7 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     dc9:	8b 45 08             	mov    0x8(%ebp),%eax
     dcc:	0f b6 00             	movzbl (%eax),%eax
     dcf:	0f b6 d0             	movzbl %al,%edx
     dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
     dd5:	0f b6 00             	movzbl (%eax),%eax
     dd8:	0f b6 c0             	movzbl %al,%eax
     ddb:	29 c2                	sub    %eax,%edx
     ddd:	89 d0                	mov    %edx,%eax
}
     ddf:	5d                   	pop    %ebp
     de0:	c3                   	ret    

00000de1 <strlen>:

uint
strlen(char *s)
{
     de1:	55                   	push   %ebp
     de2:	89 e5                	mov    %esp,%ebp
     de4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     de7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     dee:	eb 04                	jmp    df4 <strlen+0x13>
     df0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     df4:	8b 55 fc             	mov    -0x4(%ebp),%edx
     df7:	8b 45 08             	mov    0x8(%ebp),%eax
     dfa:	01 d0                	add    %edx,%eax
     dfc:	0f b6 00             	movzbl (%eax),%eax
     dff:	84 c0                	test   %al,%al
     e01:	75 ed                	jne    df0 <strlen+0xf>
    ;
  return n;
     e03:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     e06:	c9                   	leave  
     e07:	c3                   	ret    

00000e08 <memset>:

void*
memset(void *dst, int c, uint n)
{
     e08:	55                   	push   %ebp
     e09:	89 e5                	mov    %esp,%ebp
     e0b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     e0e:	8b 45 10             	mov    0x10(%ebp),%eax
     e11:	89 44 24 08          	mov    %eax,0x8(%esp)
     e15:	8b 45 0c             	mov    0xc(%ebp),%eax
     e18:	89 44 24 04          	mov    %eax,0x4(%esp)
     e1c:	8b 45 08             	mov    0x8(%ebp),%eax
     e1f:	89 04 24             	mov    %eax,(%esp)
     e22:	e8 26 ff ff ff       	call   d4d <stosb>
  return dst;
     e27:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e2a:	c9                   	leave  
     e2b:	c3                   	ret    

00000e2c <strchr>:

char*
strchr(const char *s, char c)
{
     e2c:	55                   	push   %ebp
     e2d:	89 e5                	mov    %esp,%ebp
     e2f:	83 ec 04             	sub    $0x4,%esp
     e32:	8b 45 0c             	mov    0xc(%ebp),%eax
     e35:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     e38:	eb 14                	jmp    e4e <strchr+0x22>
    if(*s == c)
     e3a:	8b 45 08             	mov    0x8(%ebp),%eax
     e3d:	0f b6 00             	movzbl (%eax),%eax
     e40:	3a 45 fc             	cmp    -0x4(%ebp),%al
     e43:	75 05                	jne    e4a <strchr+0x1e>
      return (char*)s;
     e45:	8b 45 08             	mov    0x8(%ebp),%eax
     e48:	eb 13                	jmp    e5d <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     e4a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e4e:	8b 45 08             	mov    0x8(%ebp),%eax
     e51:	0f b6 00             	movzbl (%eax),%eax
     e54:	84 c0                	test   %al,%al
     e56:	75 e2                	jne    e3a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     e58:	b8 00 00 00 00       	mov    $0x0,%eax
}
     e5d:	c9                   	leave  
     e5e:	c3                   	ret    

00000e5f <gets>:

char*
gets(char *buf, int max)
{
     e5f:	55                   	push   %ebp
     e60:	89 e5                	mov    %esp,%ebp
     e62:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     e6c:	eb 4c                	jmp    eba <gets+0x5b>
    cc = read(0, &c, 1);
     e6e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     e75:	00 
     e76:	8d 45 ef             	lea    -0x11(%ebp),%eax
     e79:	89 44 24 04          	mov    %eax,0x4(%esp)
     e7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     e84:	e8 44 01 00 00       	call   fcd <read>
     e89:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     e8c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e90:	7f 02                	jg     e94 <gets+0x35>
      break;
     e92:	eb 31                	jmp    ec5 <gets+0x66>
    buf[i++] = c;
     e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e97:	8d 50 01             	lea    0x1(%eax),%edx
     e9a:	89 55 f4             	mov    %edx,-0xc(%ebp)
     e9d:	89 c2                	mov    %eax,%edx
     e9f:	8b 45 08             	mov    0x8(%ebp),%eax
     ea2:	01 c2                	add    %eax,%edx
     ea4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     ea8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     eaa:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     eae:	3c 0a                	cmp    $0xa,%al
     eb0:	74 13                	je     ec5 <gets+0x66>
     eb2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     eb6:	3c 0d                	cmp    $0xd,%al
     eb8:	74 0b                	je     ec5 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ebd:	83 c0 01             	add    $0x1,%eax
     ec0:	3b 45 0c             	cmp    0xc(%ebp),%eax
     ec3:	7c a9                	jl     e6e <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     ec5:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ec8:	8b 45 08             	mov    0x8(%ebp),%eax
     ecb:	01 d0                	add    %edx,%eax
     ecd:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     ed0:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ed3:	c9                   	leave  
     ed4:	c3                   	ret    

00000ed5 <stat>:

int
stat(char *n, struct stat *st)
{
     ed5:	55                   	push   %ebp
     ed6:	89 e5                	mov    %esp,%ebp
     ed8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     edb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     ee2:	00 
     ee3:	8b 45 08             	mov    0x8(%ebp),%eax
     ee6:	89 04 24             	mov    %eax,(%esp)
     ee9:	e8 07 01 00 00       	call   ff5 <open>
     eee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     ef1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ef5:	79 07                	jns    efe <stat+0x29>
    return -1;
     ef7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     efc:	eb 23                	jmp    f21 <stat+0x4c>
  r = fstat(fd, st);
     efe:	8b 45 0c             	mov    0xc(%ebp),%eax
     f01:	89 44 24 04          	mov    %eax,0x4(%esp)
     f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f08:	89 04 24             	mov    %eax,(%esp)
     f0b:	e8 fd 00 00 00       	call   100d <fstat>
     f10:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f16:	89 04 24             	mov    %eax,(%esp)
     f19:	e8 bf 00 00 00       	call   fdd <close>
  return r;
     f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     f21:	c9                   	leave  
     f22:	c3                   	ret    

00000f23 <atoi>:

int
atoi(const char *s)
{
     f23:	55                   	push   %ebp
     f24:	89 e5                	mov    %esp,%ebp
     f26:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     f29:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     f30:	eb 25                	jmp    f57 <atoi+0x34>
    n = n*10 + *s++ - '0';
     f32:	8b 55 fc             	mov    -0x4(%ebp),%edx
     f35:	89 d0                	mov    %edx,%eax
     f37:	c1 e0 02             	shl    $0x2,%eax
     f3a:	01 d0                	add    %edx,%eax
     f3c:	01 c0                	add    %eax,%eax
     f3e:	89 c1                	mov    %eax,%ecx
     f40:	8b 45 08             	mov    0x8(%ebp),%eax
     f43:	8d 50 01             	lea    0x1(%eax),%edx
     f46:	89 55 08             	mov    %edx,0x8(%ebp)
     f49:	0f b6 00             	movzbl (%eax),%eax
     f4c:	0f be c0             	movsbl %al,%eax
     f4f:	01 c8                	add    %ecx,%eax
     f51:	83 e8 30             	sub    $0x30,%eax
     f54:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     f57:	8b 45 08             	mov    0x8(%ebp),%eax
     f5a:	0f b6 00             	movzbl (%eax),%eax
     f5d:	3c 2f                	cmp    $0x2f,%al
     f5f:	7e 0a                	jle    f6b <atoi+0x48>
     f61:	8b 45 08             	mov    0x8(%ebp),%eax
     f64:	0f b6 00             	movzbl (%eax),%eax
     f67:	3c 39                	cmp    $0x39,%al
     f69:	7e c7                	jle    f32 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     f6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     f6e:	c9                   	leave  
     f6f:	c3                   	ret    

00000f70 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     f70:	55                   	push   %ebp
     f71:	89 e5                	mov    %esp,%ebp
     f73:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     f76:	8b 45 08             	mov    0x8(%ebp),%eax
     f79:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
     f7f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     f82:	eb 17                	jmp    f9b <memmove+0x2b>
    *dst++ = *src++;
     f84:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f87:	8d 50 01             	lea    0x1(%eax),%edx
     f8a:	89 55 fc             	mov    %edx,-0x4(%ebp)
     f8d:	8b 55 f8             	mov    -0x8(%ebp),%edx
     f90:	8d 4a 01             	lea    0x1(%edx),%ecx
     f93:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     f96:	0f b6 12             	movzbl (%edx),%edx
     f99:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     f9b:	8b 45 10             	mov    0x10(%ebp),%eax
     f9e:	8d 50 ff             	lea    -0x1(%eax),%edx
     fa1:	89 55 10             	mov    %edx,0x10(%ebp)
     fa4:	85 c0                	test   %eax,%eax
     fa6:	7f dc                	jg     f84 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     fa8:	8b 45 08             	mov    0x8(%ebp),%eax
}
     fab:	c9                   	leave  
     fac:	c3                   	ret    

00000fad <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     fad:	b8 01 00 00 00       	mov    $0x1,%eax
     fb2:	cd 40                	int    $0x40
     fb4:	c3                   	ret    

00000fb5 <exit>:
SYSCALL(exit)
     fb5:	b8 02 00 00 00       	mov    $0x2,%eax
     fba:	cd 40                	int    $0x40
     fbc:	c3                   	ret    

00000fbd <wait>:
SYSCALL(wait)
     fbd:	b8 03 00 00 00       	mov    $0x3,%eax
     fc2:	cd 40                	int    $0x40
     fc4:	c3                   	ret    

00000fc5 <pipe>:
SYSCALL(pipe)
     fc5:	b8 04 00 00 00       	mov    $0x4,%eax
     fca:	cd 40                	int    $0x40
     fcc:	c3                   	ret    

00000fcd <read>:
SYSCALL(read)
     fcd:	b8 05 00 00 00       	mov    $0x5,%eax
     fd2:	cd 40                	int    $0x40
     fd4:	c3                   	ret    

00000fd5 <write>:
SYSCALL(write)
     fd5:	b8 10 00 00 00       	mov    $0x10,%eax
     fda:	cd 40                	int    $0x40
     fdc:	c3                   	ret    

00000fdd <close>:
SYSCALL(close)
     fdd:	b8 15 00 00 00       	mov    $0x15,%eax
     fe2:	cd 40                	int    $0x40
     fe4:	c3                   	ret    

00000fe5 <kill>:
SYSCALL(kill)
     fe5:	b8 06 00 00 00       	mov    $0x6,%eax
     fea:	cd 40                	int    $0x40
     fec:	c3                   	ret    

00000fed <exec>:
SYSCALL(exec)
     fed:	b8 07 00 00 00       	mov    $0x7,%eax
     ff2:	cd 40                	int    $0x40
     ff4:	c3                   	ret    

00000ff5 <open>:
SYSCALL(open)
     ff5:	b8 0f 00 00 00       	mov    $0xf,%eax
     ffa:	cd 40                	int    $0x40
     ffc:	c3                   	ret    

00000ffd <mknod>:
SYSCALL(mknod)
     ffd:	b8 11 00 00 00       	mov    $0x11,%eax
    1002:	cd 40                	int    $0x40
    1004:	c3                   	ret    

00001005 <unlink>:
SYSCALL(unlink)
    1005:	b8 12 00 00 00       	mov    $0x12,%eax
    100a:	cd 40                	int    $0x40
    100c:	c3                   	ret    

0000100d <fstat>:
SYSCALL(fstat)
    100d:	b8 08 00 00 00       	mov    $0x8,%eax
    1012:	cd 40                	int    $0x40
    1014:	c3                   	ret    

00001015 <link>:
SYSCALL(link)
    1015:	b8 13 00 00 00       	mov    $0x13,%eax
    101a:	cd 40                	int    $0x40
    101c:	c3                   	ret    

0000101d <mkdir>:
SYSCALL(mkdir)
    101d:	b8 14 00 00 00       	mov    $0x14,%eax
    1022:	cd 40                	int    $0x40
    1024:	c3                   	ret    

00001025 <chdir>:
SYSCALL(chdir)
    1025:	b8 09 00 00 00       	mov    $0x9,%eax
    102a:	cd 40                	int    $0x40
    102c:	c3                   	ret    

0000102d <dup>:
SYSCALL(dup)
    102d:	b8 0a 00 00 00       	mov    $0xa,%eax
    1032:	cd 40                	int    $0x40
    1034:	c3                   	ret    

00001035 <getpid>:
SYSCALL(getpid)
    1035:	b8 0b 00 00 00       	mov    $0xb,%eax
    103a:	cd 40                	int    $0x40
    103c:	c3                   	ret    

0000103d <sbrk>:
SYSCALL(sbrk)
    103d:	b8 0c 00 00 00       	mov    $0xc,%eax
    1042:	cd 40                	int    $0x40
    1044:	c3                   	ret    

00001045 <sleep>:
SYSCALL(sleep)
    1045:	b8 0d 00 00 00       	mov    $0xd,%eax
    104a:	cd 40                	int    $0x40
    104c:	c3                   	ret    

0000104d <uptime>:
SYSCALL(uptime)
    104d:	b8 0e 00 00 00       	mov    $0xe,%eax
    1052:	cd 40                	int    $0x40
    1054:	c3                   	ret    

00001055 <history>:
SYSCALL(history)
    1055:	b8 16 00 00 00       	mov    $0x16,%eax
    105a:	cd 40                	int    $0x40
    105c:	c3                   	ret    

0000105d <wait2>:
SYSCALL(wait2)
    105d:	b8 17 00 00 00       	mov    $0x17,%eax
    1062:	cd 40                	int    $0x40
    1064:	c3                   	ret    

00001065 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1065:	55                   	push   %ebp
    1066:	89 e5                	mov    %esp,%ebp
    1068:	83 ec 18             	sub    $0x18,%esp
    106b:	8b 45 0c             	mov    0xc(%ebp),%eax
    106e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1071:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1078:	00 
    1079:	8d 45 f4             	lea    -0xc(%ebp),%eax
    107c:	89 44 24 04          	mov    %eax,0x4(%esp)
    1080:	8b 45 08             	mov    0x8(%ebp),%eax
    1083:	89 04 24             	mov    %eax,(%esp)
    1086:	e8 4a ff ff ff       	call   fd5 <write>
}
    108b:	c9                   	leave  
    108c:	c3                   	ret    

0000108d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    108d:	55                   	push   %ebp
    108e:	89 e5                	mov    %esp,%ebp
    1090:	56                   	push   %esi
    1091:	53                   	push   %ebx
    1092:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1095:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    109c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    10a0:	74 17                	je     10b9 <printint+0x2c>
    10a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    10a6:	79 11                	jns    10b9 <printint+0x2c>
    neg = 1;
    10a8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    10af:	8b 45 0c             	mov    0xc(%ebp),%eax
    10b2:	f7 d8                	neg    %eax
    10b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    10b7:	eb 06                	jmp    10bf <printint+0x32>
  } else {
    x = xx;
    10b9:	8b 45 0c             	mov    0xc(%ebp),%eax
    10bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    10bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    10c6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    10c9:	8d 41 01             	lea    0x1(%ecx),%eax
    10cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    10cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
    10d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10d5:	ba 00 00 00 00       	mov    $0x0,%edx
    10da:	f7 f3                	div    %ebx
    10dc:	89 d0                	mov    %edx,%eax
    10de:	0f b6 80 9a 1a 00 00 	movzbl 0x1a9a(%eax),%eax
    10e5:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    10e9:	8b 75 10             	mov    0x10(%ebp),%esi
    10ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10ef:	ba 00 00 00 00       	mov    $0x0,%edx
    10f4:	f7 f6                	div    %esi
    10f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    10f9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    10fd:	75 c7                	jne    10c6 <printint+0x39>
  if(neg)
    10ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1103:	74 10                	je     1115 <printint+0x88>
    buf[i++] = '-';
    1105:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1108:	8d 50 01             	lea    0x1(%eax),%edx
    110b:	89 55 f4             	mov    %edx,-0xc(%ebp)
    110e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1113:	eb 1f                	jmp    1134 <printint+0xa7>
    1115:	eb 1d                	jmp    1134 <printint+0xa7>
    putc(fd, buf[i]);
    1117:	8d 55 dc             	lea    -0x24(%ebp),%edx
    111a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    111d:	01 d0                	add    %edx,%eax
    111f:	0f b6 00             	movzbl (%eax),%eax
    1122:	0f be c0             	movsbl %al,%eax
    1125:	89 44 24 04          	mov    %eax,0x4(%esp)
    1129:	8b 45 08             	mov    0x8(%ebp),%eax
    112c:	89 04 24             	mov    %eax,(%esp)
    112f:	e8 31 ff ff ff       	call   1065 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1134:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1138:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    113c:	79 d9                	jns    1117 <printint+0x8a>
    putc(fd, buf[i]);
}
    113e:	83 c4 30             	add    $0x30,%esp
    1141:	5b                   	pop    %ebx
    1142:	5e                   	pop    %esi
    1143:	5d                   	pop    %ebp
    1144:	c3                   	ret    

00001145 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1145:	55                   	push   %ebp
    1146:	89 e5                	mov    %esp,%ebp
    1148:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    114b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1152:	8d 45 0c             	lea    0xc(%ebp),%eax
    1155:	83 c0 04             	add    $0x4,%eax
    1158:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    115b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1162:	e9 7c 01 00 00       	jmp    12e3 <printf+0x19e>
    c = fmt[i] & 0xff;
    1167:	8b 55 0c             	mov    0xc(%ebp),%edx
    116a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    116d:	01 d0                	add    %edx,%eax
    116f:	0f b6 00             	movzbl (%eax),%eax
    1172:	0f be c0             	movsbl %al,%eax
    1175:	25 ff 00 00 00       	and    $0xff,%eax
    117a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    117d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1181:	75 2c                	jne    11af <printf+0x6a>
      if(c == '%'){
    1183:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1187:	75 0c                	jne    1195 <printf+0x50>
        state = '%';
    1189:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1190:	e9 4a 01 00 00       	jmp    12df <printf+0x19a>
      } else {
        putc(fd, c);
    1195:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1198:	0f be c0             	movsbl %al,%eax
    119b:	89 44 24 04          	mov    %eax,0x4(%esp)
    119f:	8b 45 08             	mov    0x8(%ebp),%eax
    11a2:	89 04 24             	mov    %eax,(%esp)
    11a5:	e8 bb fe ff ff       	call   1065 <putc>
    11aa:	e9 30 01 00 00       	jmp    12df <printf+0x19a>
      }
    } else if(state == '%'){
    11af:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    11b3:	0f 85 26 01 00 00    	jne    12df <printf+0x19a>
      if(c == 'd'){
    11b9:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    11bd:	75 2d                	jne    11ec <printf+0xa7>
        printint(fd, *ap, 10, 1);
    11bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11c2:	8b 00                	mov    (%eax),%eax
    11c4:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    11cb:	00 
    11cc:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    11d3:	00 
    11d4:	89 44 24 04          	mov    %eax,0x4(%esp)
    11d8:	8b 45 08             	mov    0x8(%ebp),%eax
    11db:	89 04 24             	mov    %eax,(%esp)
    11de:	e8 aa fe ff ff       	call   108d <printint>
        ap++;
    11e3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11e7:	e9 ec 00 00 00       	jmp    12d8 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
    11ec:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    11f0:	74 06                	je     11f8 <printf+0xb3>
    11f2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    11f6:	75 2d                	jne    1225 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    11f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11fb:	8b 00                	mov    (%eax),%eax
    11fd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    1204:	00 
    1205:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    120c:	00 
    120d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1211:	8b 45 08             	mov    0x8(%ebp),%eax
    1214:	89 04 24             	mov    %eax,(%esp)
    1217:	e8 71 fe ff ff       	call   108d <printint>
        ap++;
    121c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1220:	e9 b3 00 00 00       	jmp    12d8 <printf+0x193>
      } else if(c == 's'){
    1225:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1229:	75 45                	jne    1270 <printf+0x12b>
        s = (char*)*ap;
    122b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    122e:	8b 00                	mov    (%eax),%eax
    1230:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1233:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1237:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    123b:	75 09                	jne    1246 <printf+0x101>
          s = "(null)";
    123d:	c7 45 f4 04 16 00 00 	movl   $0x1604,-0xc(%ebp)
        while(*s != 0){
    1244:	eb 1e                	jmp    1264 <printf+0x11f>
    1246:	eb 1c                	jmp    1264 <printf+0x11f>
          putc(fd, *s);
    1248:	8b 45 f4             	mov    -0xc(%ebp),%eax
    124b:	0f b6 00             	movzbl (%eax),%eax
    124e:	0f be c0             	movsbl %al,%eax
    1251:	89 44 24 04          	mov    %eax,0x4(%esp)
    1255:	8b 45 08             	mov    0x8(%ebp),%eax
    1258:	89 04 24             	mov    %eax,(%esp)
    125b:	e8 05 fe ff ff       	call   1065 <putc>
          s++;
    1260:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1264:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1267:	0f b6 00             	movzbl (%eax),%eax
    126a:	84 c0                	test   %al,%al
    126c:	75 da                	jne    1248 <printf+0x103>
    126e:	eb 68                	jmp    12d8 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1270:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1274:	75 1d                	jne    1293 <printf+0x14e>
        putc(fd, *ap);
    1276:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1279:	8b 00                	mov    (%eax),%eax
    127b:	0f be c0             	movsbl %al,%eax
    127e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1282:	8b 45 08             	mov    0x8(%ebp),%eax
    1285:	89 04 24             	mov    %eax,(%esp)
    1288:	e8 d8 fd ff ff       	call   1065 <putc>
        ap++;
    128d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1291:	eb 45                	jmp    12d8 <printf+0x193>
      } else if(c == '%'){
    1293:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1297:	75 17                	jne    12b0 <printf+0x16b>
        putc(fd, c);
    1299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    129c:	0f be c0             	movsbl %al,%eax
    129f:	89 44 24 04          	mov    %eax,0x4(%esp)
    12a3:	8b 45 08             	mov    0x8(%ebp),%eax
    12a6:	89 04 24             	mov    %eax,(%esp)
    12a9:	e8 b7 fd ff ff       	call   1065 <putc>
    12ae:	eb 28                	jmp    12d8 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    12b0:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    12b7:	00 
    12b8:	8b 45 08             	mov    0x8(%ebp),%eax
    12bb:	89 04 24             	mov    %eax,(%esp)
    12be:	e8 a2 fd ff ff       	call   1065 <putc>
        putc(fd, c);
    12c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12c6:	0f be c0             	movsbl %al,%eax
    12c9:	89 44 24 04          	mov    %eax,0x4(%esp)
    12cd:	8b 45 08             	mov    0x8(%ebp),%eax
    12d0:	89 04 24             	mov    %eax,(%esp)
    12d3:	e8 8d fd ff ff       	call   1065 <putc>
      }
      state = 0;
    12d8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    12df:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    12e3:	8b 55 0c             	mov    0xc(%ebp),%edx
    12e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12e9:	01 d0                	add    %edx,%eax
    12eb:	0f b6 00             	movzbl (%eax),%eax
    12ee:	84 c0                	test   %al,%al
    12f0:	0f 85 71 fe ff ff    	jne    1167 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    12f6:	c9                   	leave  
    12f7:	c3                   	ret    

000012f8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12f8:	55                   	push   %ebp
    12f9:	89 e5                	mov    %esp,%ebp
    12fb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12fe:	8b 45 08             	mov    0x8(%ebp),%eax
    1301:	83 e8 08             	sub    $0x8,%eax
    1304:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1307:	a1 2c 1b 00 00       	mov    0x1b2c,%eax
    130c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    130f:	eb 24                	jmp    1335 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1311:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1314:	8b 00                	mov    (%eax),%eax
    1316:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1319:	77 12                	ja     132d <free+0x35>
    131b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    131e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1321:	77 24                	ja     1347 <free+0x4f>
    1323:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1326:	8b 00                	mov    (%eax),%eax
    1328:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    132b:	77 1a                	ja     1347 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    132d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1330:	8b 00                	mov    (%eax),%eax
    1332:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1335:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1338:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    133b:	76 d4                	jbe    1311 <free+0x19>
    133d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1340:	8b 00                	mov    (%eax),%eax
    1342:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1345:	76 ca                	jbe    1311 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1347:	8b 45 f8             	mov    -0x8(%ebp),%eax
    134a:	8b 40 04             	mov    0x4(%eax),%eax
    134d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1354:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1357:	01 c2                	add    %eax,%edx
    1359:	8b 45 fc             	mov    -0x4(%ebp),%eax
    135c:	8b 00                	mov    (%eax),%eax
    135e:	39 c2                	cmp    %eax,%edx
    1360:	75 24                	jne    1386 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1362:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1365:	8b 50 04             	mov    0x4(%eax),%edx
    1368:	8b 45 fc             	mov    -0x4(%ebp),%eax
    136b:	8b 00                	mov    (%eax),%eax
    136d:	8b 40 04             	mov    0x4(%eax),%eax
    1370:	01 c2                	add    %eax,%edx
    1372:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1375:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1378:	8b 45 fc             	mov    -0x4(%ebp),%eax
    137b:	8b 00                	mov    (%eax),%eax
    137d:	8b 10                	mov    (%eax),%edx
    137f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1382:	89 10                	mov    %edx,(%eax)
    1384:	eb 0a                	jmp    1390 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1386:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1389:	8b 10                	mov    (%eax),%edx
    138b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    138e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1390:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1393:	8b 40 04             	mov    0x4(%eax),%eax
    1396:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    139d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13a0:	01 d0                	add    %edx,%eax
    13a2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    13a5:	75 20                	jne    13c7 <free+0xcf>
    p->s.size += bp->s.size;
    13a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13aa:	8b 50 04             	mov    0x4(%eax),%edx
    13ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13b0:	8b 40 04             	mov    0x4(%eax),%eax
    13b3:	01 c2                	add    %eax,%edx
    13b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13b8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    13bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13be:	8b 10                	mov    (%eax),%edx
    13c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13c3:	89 10                	mov    %edx,(%eax)
    13c5:	eb 08                	jmp    13cf <free+0xd7>
  } else
    p->s.ptr = bp;
    13c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13ca:	8b 55 f8             	mov    -0x8(%ebp),%edx
    13cd:	89 10                	mov    %edx,(%eax)
  freep = p;
    13cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13d2:	a3 2c 1b 00 00       	mov    %eax,0x1b2c
}
    13d7:	c9                   	leave  
    13d8:	c3                   	ret    

000013d9 <morecore>:

static Header*
morecore(uint nu)
{
    13d9:	55                   	push   %ebp
    13da:	89 e5                	mov    %esp,%ebp
    13dc:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    13df:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    13e6:	77 07                	ja     13ef <morecore+0x16>
    nu = 4096;
    13e8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    13ef:	8b 45 08             	mov    0x8(%ebp),%eax
    13f2:	c1 e0 03             	shl    $0x3,%eax
    13f5:	89 04 24             	mov    %eax,(%esp)
    13f8:	e8 40 fc ff ff       	call   103d <sbrk>
    13fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1400:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1404:	75 07                	jne    140d <morecore+0x34>
    return 0;
    1406:	b8 00 00 00 00       	mov    $0x0,%eax
    140b:	eb 22                	jmp    142f <morecore+0x56>
  hp = (Header*)p;
    140d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1410:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1413:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1416:	8b 55 08             	mov    0x8(%ebp),%edx
    1419:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    141c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    141f:	83 c0 08             	add    $0x8,%eax
    1422:	89 04 24             	mov    %eax,(%esp)
    1425:	e8 ce fe ff ff       	call   12f8 <free>
  return freep;
    142a:	a1 2c 1b 00 00       	mov    0x1b2c,%eax
}
    142f:	c9                   	leave  
    1430:	c3                   	ret    

00001431 <malloc>:

void*
malloc(uint nbytes)
{
    1431:	55                   	push   %ebp
    1432:	89 e5                	mov    %esp,%ebp
    1434:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1437:	8b 45 08             	mov    0x8(%ebp),%eax
    143a:	83 c0 07             	add    $0x7,%eax
    143d:	c1 e8 03             	shr    $0x3,%eax
    1440:	83 c0 01             	add    $0x1,%eax
    1443:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1446:	a1 2c 1b 00 00       	mov    0x1b2c,%eax
    144b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    144e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1452:	75 23                	jne    1477 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1454:	c7 45 f0 24 1b 00 00 	movl   $0x1b24,-0x10(%ebp)
    145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    145e:	a3 2c 1b 00 00       	mov    %eax,0x1b2c
    1463:	a1 2c 1b 00 00       	mov    0x1b2c,%eax
    1468:	a3 24 1b 00 00       	mov    %eax,0x1b24
    base.s.size = 0;
    146d:	c7 05 28 1b 00 00 00 	movl   $0x0,0x1b28
    1474:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1477:	8b 45 f0             	mov    -0x10(%ebp),%eax
    147a:	8b 00                	mov    (%eax),%eax
    147c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    147f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1482:	8b 40 04             	mov    0x4(%eax),%eax
    1485:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1488:	72 4d                	jb     14d7 <malloc+0xa6>
      if(p->s.size == nunits)
    148a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    148d:	8b 40 04             	mov    0x4(%eax),%eax
    1490:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1493:	75 0c                	jne    14a1 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1495:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1498:	8b 10                	mov    (%eax),%edx
    149a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    149d:	89 10                	mov    %edx,(%eax)
    149f:	eb 26                	jmp    14c7 <malloc+0x96>
      else {
        p->s.size -= nunits;
    14a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14a4:	8b 40 04             	mov    0x4(%eax),%eax
    14a7:	2b 45 ec             	sub    -0x14(%ebp),%eax
    14aa:	89 c2                	mov    %eax,%edx
    14ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14af:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    14b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14b5:	8b 40 04             	mov    0x4(%eax),%eax
    14b8:	c1 e0 03             	shl    $0x3,%eax
    14bb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    14be:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
    14c4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    14c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14ca:	a3 2c 1b 00 00       	mov    %eax,0x1b2c
      return (void*)(p + 1);
    14cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14d2:	83 c0 08             	add    $0x8,%eax
    14d5:	eb 38                	jmp    150f <malloc+0xde>
    }
    if(p == freep)
    14d7:	a1 2c 1b 00 00       	mov    0x1b2c,%eax
    14dc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    14df:	75 1b                	jne    14fc <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    14e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
    14e4:	89 04 24             	mov    %eax,(%esp)
    14e7:	e8 ed fe ff ff       	call   13d9 <morecore>
    14ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    14ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14f3:	75 07                	jne    14fc <malloc+0xcb>
        return 0;
    14f5:	b8 00 00 00 00       	mov    $0x0,%eax
    14fa:	eb 13                	jmp    150f <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    14fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1502:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1505:	8b 00                	mov    (%eax),%eax
    1507:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    150a:	e9 70 ff ff ff       	jmp    147f <malloc+0x4e>
}
    150f:	c9                   	leave  
    1510:	c3                   	ret    
