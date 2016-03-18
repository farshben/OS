
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 09 3f 10 80       	mov    $0x80103f09,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 e0 8e 10 	movl   $0x80108ee0,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100049:	e8 6b 57 00 00       	call   801057b9 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 70 15 11 80 64 	movl   $0x80111564,0x80111570
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 74 15 11 80 64 	movl   $0x80111564,0x80111574
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 74 15 11 80       	mov    0x80111574,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 74 15 11 80       	mov    %eax,0x80111574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801000bd:	e8 18 57 00 00       	call   801057da <acquire>

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 74 15 11 80       	mov    0x80111574,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->blockno == blockno){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100104:	e8 33 57 00 00       	call   8010583c <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 d6 10 	movl   $0x8010d660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 67 53 00 00       	call   8010548b <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 70 15 11 80       	mov    0x80111570,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010017c:	e8 bb 56 00 00       	call   8010583c <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 e7 8e 10 80 	movl   $0x80108ee7,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 c5 2d 00 00       	call   80102f9d <iderw>
  }
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 f8 8e 10 80 	movl   $0x80108ef8,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 88 2d 00 00       	call   80102f9d <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 ff 8e 10 80 	movl   $0x80108eff,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010023c:	e8 99 55 00 00       	call   801057da <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 74 15 11 80       	mov    0x80111574,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 74 15 11 80       	mov    %eax,0x80111574

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 c5 52 00 00       	call   80105567 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801002a9:	e8 8e 55 00 00       	call   8010583c <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 d8 07 00 00       	call   80100b67 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801003bb:	e8 1a 54 00 00       	call   801057da <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 06 8f 10 80 	movl   $0x80108f06,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 71 07 00 00       	call   80100b67 <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec 0f 8f 10 80 	movl   $0x80108f0f,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 9b 06 00 00       	call   80100b67 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 7f 06 00 00       	call   80100b67 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 71 06 00 00       	call   80100b67 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 66 06 00 00       	call   80100b67 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100533:	e8 04 53 00 00       	call   8010583c <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 16 8f 10 80 	movl   $0x80108f16,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 25 8f 10 80 	movl   $0x80108f25,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 f7 52 00 00       	call   8010588b <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 27 8f 10 80 	movl   $0x80108f27,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <history_insert>:
    char buf[MAX_HISTORY][INPUT_BUF];
} classHistory;

classHistory inputHistory;

void history_insert(classHistory* pHistory,char* line ){
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 18             	sub    $0x18,%esp
    memmove(pHistory->buf[1] ,pHistory->buf , INPUT_BUF*(MAX_HISTORY - 1));
801005d0:	8b 45 08             	mov    0x8(%ebp),%eax
801005d3:	8d 50 08             	lea    0x8(%eax),%edx
801005d6:	8b 45 08             	mov    0x8(%ebp),%eax
801005d9:	05 88 00 00 00       	add    $0x88,%eax
801005de:	c7 44 24 08 80 07 00 	movl   $0x780,0x8(%esp)
801005e5:	00 
801005e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801005ea:	89 04 24             	mov    %eax,(%esp)
801005ed:	e8 0b 55 00 00       	call   80105afd <memmove>
    memmove(pHistory->buf,line, INPUT_BUF);
801005f2:	8b 45 08             	mov    0x8(%ebp),%eax
801005f5:	8d 50 08             	lea    0x8(%eax),%edx
801005f8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801005ff:	00 
80100600:	8b 45 0c             	mov    0xc(%ebp),%eax
80100603:	89 44 24 04          	mov    %eax,0x4(%esp)
80100607:	89 14 24             	mov    %edx,(%esp)
8010060a:	e8 ee 54 00 00       	call   80105afd <memmove>
    if(pHistory->size < MAX_HISTORY - 1) pHistory->size++;
8010060f:	8b 45 08             	mov    0x8(%ebp),%eax
80100612:	8b 40 04             	mov    0x4(%eax),%eax
80100615:	83 f8 0e             	cmp    $0xe,%eax
80100618:	7f 0f                	jg     80100629 <history_insert+0x5f>
8010061a:	8b 45 08             	mov    0x8(%ebp),%eax
8010061d:	8b 40 04             	mov    0x4(%eax),%eax
80100620:	8d 50 01             	lea    0x1(%eax),%edx
80100623:	8b 45 08             	mov    0x8(%ebp),%eax
80100626:	89 50 04             	mov    %edx,0x4(%eax)
}
80100629:	c9                   	leave  
8010062a:	c3                   	ret    

8010062b <history_get>:

char* history_get(classHistory* pHistory, int index ){
8010062b:	55                   	push   %ebp
8010062c:	89 e5                	mov    %esp,%ebp
    if(index >= pHistory->size || index <0) return 0;
8010062e:	8b 45 08             	mov    0x8(%ebp),%eax
80100631:	8b 40 04             	mov    0x4(%eax),%eax
80100634:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100637:	7e 06                	jle    8010063f <history_get+0x14>
80100639:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010063d:	79 07                	jns    80100646 <history_get+0x1b>
8010063f:	b8 00 00 00 00       	mov    $0x0,%eax
80100644:	eb 10                	jmp    80100656 <history_get+0x2b>
    return pHistory->buf[index];
80100646:	8b 45 0c             	mov    0xc(%ebp),%eax
80100649:	c1 e0 07             	shl    $0x7,%eax
8010064c:	89 c2                	mov    %eax,%edx
8010064e:	8b 45 08             	mov    0x8(%ebp),%eax
80100651:	01 d0                	add    %edx,%eax
80100653:	83 c0 08             	add    $0x8,%eax
}
80100656:	5d                   	pop    %ebp
80100657:	c3                   	ret    

80100658 <history_get_string_size>:

int history_get_string_size(char* str){
80100658:	55                   	push   %ebp
80100659:	89 e5                	mov    %esp,%ebp
8010065b:	83 ec 10             	sub    $0x10,%esp
  int counter =0;
8010065e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(str[counter]!='\n'){
80100665:	eb 04                	jmp    8010066b <history_get_string_size+0x13>
    counter++;
80100667:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    return pHistory->buf[index];
}

int history_get_string_size(char* str){
  int counter =0;
  while(str[counter]!='\n'){
8010066b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010066e:	8b 45 08             	mov    0x8(%ebp),%eax
80100671:	01 d0                	add    %edx,%eax
80100673:	0f b6 00             	movzbl (%eax),%eax
80100676:	3c 0a                	cmp    $0xa,%al
80100678:	75 ed                	jne    80100667 <history_get_string_size+0xf>
    counter++;
  }
  return counter;
8010067a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010067d:	c9                   	leave  
8010067e:	c3                   	ret    

8010067f <history>:

int history(char* buffer,int historyId){
8010067f:	55                   	push   %ebp
80100680:	89 e5                	mov    %esp,%ebp
80100682:	83 ec 28             	sub    $0x28,%esp
  if(historyId >= MAX_HISTORY || historyId < 0) return -2;
80100685:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
80100689:	7f 06                	jg     80100691 <history+0x12>
8010068b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010068f:	79 07                	jns    80100698 <history+0x19>
80100691:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
80100696:	eb 5a                	jmp    801006f2 <history+0x73>
  if(historyId > inputHistory.size) return -1;
80100698:	a1 84 17 11 80       	mov    0x80111784,%eax
8010069d:	3b 45 0c             	cmp    0xc(%ebp),%eax
801006a0:	7d 07                	jge    801006a9 <history+0x2a>
801006a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801006a7:	eb 49                	jmp    801006f2 <history+0x73>
  char* tmp = history_get(&inputHistory,historyId);
801006a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801006ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801006b0:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
801006b7:	e8 6f ff ff ff       	call   8010062b <history_get>
801006bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(tmp == 0) return -1;
801006bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006c3:	75 07                	jne    801006cc <history+0x4d>
801006c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801006ca:	eb 26                	jmp    801006f2 <history+0x73>
  memmove(buffer,tmp,history_get_string_size(tmp));
801006cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006cf:	89 04 24             	mov    %eax,(%esp)
801006d2:	e8 81 ff ff ff       	call   80100658 <history_get_string_size>
801006d7:	89 44 24 08          	mov    %eax,0x8(%esp)
801006db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006de:	89 44 24 04          	mov    %eax,0x4(%esp)
801006e2:	8b 45 08             	mov    0x8(%ebp),%eax
801006e5:	89 04 24             	mov    %eax,(%esp)
801006e8:	e8 10 54 00 00       	call   80105afd <memmove>
//   memset(buffer+history_get_string_size(tmp)+1,'\0',1);
  return 0;
801006ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801006f2:	c9                   	leave  
801006f3:	c3                   	ret    

801006f4 <cgaputc>:
// }
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801006f4:	55                   	push   %ebp
801006f5:	89 e5                	mov    %esp,%ebp
801006f7:	53                   	push   %ebx
801006f8:	83 ec 44             	sub    $0x44,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801006fb:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100702:	00 
80100703:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010070a:	e8 be fb ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
8010070f:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100716:	e8 95 fb ff ff       	call   801002b0 <inb>
8010071b:	0f b6 c0             	movzbl %al,%eax
8010071e:	c1 e0 08             	shl    $0x8,%eax
80100721:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100724:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010072b:	00 
8010072c:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100733:	e8 95 fb ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
80100738:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010073f:	e8 6c fb ff ff       	call   801002b0 <inb>
80100744:	0f b6 c0             	movzbl %al,%eax
80100747:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010074a:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010074e:	75 33                	jne    80100783 <cgaputc+0x8f>
    pos += 80 - pos%80;
80100750:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100753:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100758:	89 c8                	mov    %ecx,%eax
8010075a:	f7 ea                	imul   %edx
8010075c:	c1 fa 05             	sar    $0x5,%edx
8010075f:	89 c8                	mov    %ecx,%eax
80100761:	c1 f8 1f             	sar    $0x1f,%eax
80100764:	29 c2                	sub    %eax,%edx
80100766:	89 d0                	mov    %edx,%eax
80100768:	c1 e0 02             	shl    $0x2,%eax
8010076b:	01 d0                	add    %edx,%eax
8010076d:	c1 e0 04             	shl    $0x4,%eax
80100770:	29 c1                	sub    %eax,%ecx
80100772:	89 ca                	mov    %ecx,%edx
80100774:	b8 50 00 00 00       	mov    $0x50,%eax
80100779:	29 d0                	sub    %edx,%eax
8010077b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010077e:	e9 10 03 00 00       	jmp    80100a93 <cgaputc+0x39f>
  else if(c == BACKSPACE){
80100783:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078a:	75 4a                	jne    801007d6 <cgaputc+0xe2>
    if(pos > 0){
8010078c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100790:	0f 8e fd 02 00 00    	jle    80100a93 <cgaputc+0x39f>
      --pos;
80100796:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
      memmove(crt + pos, crt+pos + 1, sizeof(crt[0])*23*80 - pos);
8010079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010079d:	ba 60 0e 00 00       	mov    $0xe60,%edx
801007a2:	89 d1                	mov    %edx,%ecx
801007a4:	29 c1                	sub    %eax,%ecx
801007a6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007ae:	83 c2 01             	add    $0x1,%edx
801007b1:	01 d2                	add    %edx,%edx
801007b3:	01 c2                	add    %eax,%edx
801007b5:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007ba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801007bd:	01 db                	add    %ebx,%ebx
801007bf:	01 d8                	add    %ebx,%eax
801007c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801007c5:	89 54 24 04          	mov    %edx,0x4(%esp)
801007c9:	89 04 24             	mov    %eax,(%esp)
801007cc:	e8 2c 53 00 00       	call   80105afd <memmove>
801007d1:	e9 bd 02 00 00       	jmp    80100a93 <cgaputc+0x39f>
    }
  }
  else if(c == LEFT_ARROW){
801007d6:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
801007dd:	75 13                	jne    801007f2 <cgaputc+0xfe>
    if(pos > 0) pos--;
801007df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801007e3:	0f 8e aa 02 00 00    	jle    80100a93 <cgaputc+0x39f>
801007e9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801007ed:	e9 a1 02 00 00       	jmp    80100a93 <cgaputc+0x39f>
  }
  else if(c == RIGHT_ARROW){
801007f2:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
801007f9:	75 17                	jne    80100812 <cgaputc+0x11e>
    if(pos < sizeof(crt[0])*23*80) ++pos;
801007fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007fe:	3d 5f 0e 00 00       	cmp    $0xe5f,%eax
80100803:	0f 87 8a 02 00 00    	ja     80100a93 <cgaputc+0x39f>
80100809:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010080d:	e9 81 02 00 00       	jmp    80100a93 <cgaputc+0x39f>
  }
  else if(c == UP_ARROW){
80100812:	81 7d 08 e2 00 00 00 	cmpl   $0xe2,0x8(%ebp)
80100819:	0f 85 d8 00 00 00    	jne    801008f7 <cgaputc+0x203>
   if(inputHistory.current < inputHistory.size) {
8010081f:	8b 15 80 17 11 80    	mov    0x80111780,%edx
80100825:	a1 84 17 11 80       	mov    0x80111784,%eax
8010082a:	39 c2                	cmp    %eax,%edx
8010082c:	0f 8d c0 00 00 00    	jge    801008f2 <cgaputc+0x1fe>
       int todelete = pos%80 -2;
80100832:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100835:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010083a:	89 c8                	mov    %ecx,%eax
8010083c:	f7 ea                	imul   %edx
8010083e:	c1 fa 05             	sar    $0x5,%edx
80100841:	89 c8                	mov    %ecx,%eax
80100843:	c1 f8 1f             	sar    $0x1f,%eax
80100846:	29 c2                	sub    %eax,%edx
80100848:	89 d0                	mov    %edx,%eax
8010084a:	c1 e0 02             	shl    $0x2,%eax
8010084d:	01 d0                	add    %edx,%eax
8010084f:	c1 e0 04             	shl    $0x4,%eax
80100852:	29 c1                	sub    %eax,%ecx
80100854:	89 ca                	mov    %ecx,%edx
80100856:	8d 42 fe             	lea    -0x2(%edx),%eax
80100859:	89 45 e4             	mov    %eax,-0x1c(%ebp)
       pos -= todelete;
8010085c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010085f:	29 45 f4             	sub    %eax,-0xc(%ebp)
       int counter =0;
80100862:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
       int size = history_get_string_size(inputHistory.buf[inputHistory.current]);
80100869:	a1 80 17 11 80       	mov    0x80111780,%eax
8010086e:	c1 e0 07             	shl    $0x7,%eax
80100871:	05 80 17 11 80       	add    $0x80111780,%eax
80100876:	83 c0 08             	add    $0x8,%eax
80100879:	89 04 24             	mov    %eax,(%esp)
8010087c:	e8 d7 fd ff ff       	call   80100658 <history_get_string_size>
80100881:	89 45 e0             	mov    %eax,-0x20(%ebp)
       while(counter<size){
80100884:	eb 37                	jmp    801008bd <cgaputc+0x1c9>
	crt[pos]=(inputHistory.buf[inputHistory.current][counter]&0xff) | 0x0700;
80100886:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010088b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010088e:	01 d2                	add    %edx,%edx
80100890:	01 c2                	add    %eax,%edx
80100892:	a1 80 17 11 80       	mov    0x80111780,%eax
80100897:	c1 e0 07             	shl    $0x7,%eax
8010089a:	89 c1                	mov    %eax,%ecx
8010089c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010089f:	01 c8                	add    %ecx,%eax
801008a1:	05 80 17 11 80       	add    $0x80111780,%eax
801008a6:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801008aa:	66 98                	cbtw   
801008ac:	0f b6 c0             	movzbl %al,%eax
801008af:	80 cc 07             	or     $0x7,%ah
801008b2:	66 89 02             	mov    %ax,(%edx)
	pos++;
801008b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	counter++;
801008b9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
   if(inputHistory.current < inputHistory.size) {
       int todelete = pos%80 -2;
       pos -= todelete;
       int counter =0;
       int size = history_get_string_size(inputHistory.buf[inputHistory.current]);
       while(counter<size){
801008bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008c0:	3b 45 e0             	cmp    -0x20(%ebp),%eax
801008c3:	7c c1                	jl     80100886 <cgaputc+0x192>
	crt[pos]=(inputHistory.buf[inputHistory.current][counter]&0xff) | 0x0700;
	pos++;
	counter++;
       }
       while(counter < todelete){
801008c5:	eb 23                	jmp    801008ea <cgaputc+0x1f6>
	 crt[pos + todelete - counter -1]=' ' | 0x0700;
801008c7:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801008cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801008cf:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801008d2:	01 ca                	add    %ecx,%edx
801008d4:	2b 55 f0             	sub    -0x10(%ebp),%edx
801008d7:	81 c2 ff ff ff 7f    	add    $0x7fffffff,%edx
801008dd:	01 d2                	add    %edx,%edx
801008df:	01 d0                	add    %edx,%eax
801008e1:	66 c7 00 20 07       	movw   $0x720,(%eax)
	 counter++;
801008e6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
       while(counter<size){
	crt[pos]=(inputHistory.buf[inputHistory.current][counter]&0xff) | 0x0700;
	pos++;
	counter++;
       }
       while(counter < todelete){
801008ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008ed:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
801008f0:	7c d5                	jl     801008c7 <cgaputc+0x1d3>
801008f2:	e9 9c 01 00 00       	jmp    80100a93 <cgaputc+0x39f>
	 crt[pos + todelete - counter -1]=' ' | 0x0700;
	 counter++;
       }
   }
  }
  else if(c == DOWN_ARROW){
801008f7:	81 7d 08 e3 00 00 00 	cmpl   $0xe3,0x8(%ebp)
801008fe:	0f 85 38 01 00 00    	jne    80100a3c <cgaputc+0x348>
   if(inputHistory.current >= 0) {
80100904:	a1 80 17 11 80       	mov    0x80111780,%eax
80100909:	85 c0                	test   %eax,%eax
8010090b:	0f 88 c5 00 00 00    	js     801009d6 <cgaputc+0x2e2>
       int todelete = pos%80 -2;
80100911:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100914:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100919:	89 c8                	mov    %ecx,%eax
8010091b:	f7 ea                	imul   %edx
8010091d:	c1 fa 05             	sar    $0x5,%edx
80100920:	89 c8                	mov    %ecx,%eax
80100922:	c1 f8 1f             	sar    $0x1f,%eax
80100925:	29 c2                	sub    %eax,%edx
80100927:	89 d0                	mov    %edx,%eax
80100929:	c1 e0 02             	shl    $0x2,%eax
8010092c:	01 d0                	add    %edx,%eax
8010092e:	c1 e0 04             	shl    $0x4,%eax
80100931:	29 c1                	sub    %eax,%ecx
80100933:	89 ca                	mov    %ecx,%edx
80100935:	8d 42 fe             	lea    -0x2(%edx),%eax
80100938:	89 45 dc             	mov    %eax,-0x24(%ebp)
       pos -= todelete;
8010093b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010093e:	29 45 f4             	sub    %eax,-0xc(%ebp)
       int counter =0;
80100941:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
       int size = history_get_string_size(inputHistory.buf[inputHistory.current]);
80100948:	a1 80 17 11 80       	mov    0x80111780,%eax
8010094d:	c1 e0 07             	shl    $0x7,%eax
80100950:	05 80 17 11 80       	add    $0x80111780,%eax
80100955:	83 c0 08             	add    $0x8,%eax
80100958:	89 04 24             	mov    %eax,(%esp)
8010095b:	e8 f8 fc ff ff       	call   80100658 <history_get_string_size>
80100960:	89 45 d8             	mov    %eax,-0x28(%ebp)
       while(counter<size){
80100963:	eb 37                	jmp    8010099c <cgaputc+0x2a8>
	crt[pos]=(inputHistory.buf[inputHistory.current][counter]&0xff) | 0x0700;
80100965:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010096a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010096d:	01 d2                	add    %edx,%edx
8010096f:	01 c2                	add    %eax,%edx
80100971:	a1 80 17 11 80       	mov    0x80111780,%eax
80100976:	c1 e0 07             	shl    $0x7,%eax
80100979:	89 c1                	mov    %eax,%ecx
8010097b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010097e:	01 c8                	add    %ecx,%eax
80100980:	05 80 17 11 80       	add    $0x80111780,%eax
80100985:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80100989:	66 98                	cbtw   
8010098b:	0f b6 c0             	movzbl %al,%eax
8010098e:	80 cc 07             	or     $0x7,%ah
80100991:	66 89 02             	mov    %ax,(%edx)
	pos++;
80100994:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	counter++;
80100998:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
   if(inputHistory.current >= 0) {
       int todelete = pos%80 -2;
       pos -= todelete;
       int counter =0;
       int size = history_get_string_size(inputHistory.buf[inputHistory.current]);
       while(counter<size){
8010099c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010099f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
801009a2:	7c c1                	jl     80100965 <cgaputc+0x271>
	crt[pos]=(inputHistory.buf[inputHistory.current][counter]&0xff) | 0x0700;
	pos++;
	counter++;
       }
       while(counter < todelete){
801009a4:	eb 23                	jmp    801009c9 <cgaputc+0x2d5>
	 crt[pos + todelete - counter -1]=' ' | 0x0700;
801009a6:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801009ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
801009ae:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801009b1:	01 ca                	add    %ecx,%edx
801009b3:	2b 55 ec             	sub    -0x14(%ebp),%edx
801009b6:	81 c2 ff ff ff 7f    	add    $0x7fffffff,%edx
801009bc:	01 d2                	add    %edx,%edx
801009be:	01 d0                	add    %edx,%eax
801009c0:	66 c7 00 20 07       	movw   $0x720,(%eax)
	 counter++;
801009c5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
       while(counter<size){
	crt[pos]=(inputHistory.buf[inputHistory.current][counter]&0xff) | 0x0700;
	pos++;
	counter++;
       }
       while(counter < todelete){
801009c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801009cc:	3b 45 dc             	cmp    -0x24(%ebp),%eax
801009cf:	7c d5                	jl     801009a6 <cgaputc+0x2b2>
801009d1:	e9 bd 00 00 00       	jmp    80100a93 <cgaputc+0x39f>
	 crt[pos + todelete - counter -1]=' ' | 0x0700;
	 counter++;
       }
   }
   else{
     int todelete = pos%80 -2;
801009d6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801009d9:	ba 67 66 66 66       	mov    $0x66666667,%edx
801009de:	89 c8                	mov    %ecx,%eax
801009e0:	f7 ea                	imul   %edx
801009e2:	c1 fa 05             	sar    $0x5,%edx
801009e5:	89 c8                	mov    %ecx,%eax
801009e7:	c1 f8 1f             	sar    $0x1f,%eax
801009ea:	29 c2                	sub    %eax,%edx
801009ec:	89 d0                	mov    %edx,%eax
801009ee:	c1 e0 02             	shl    $0x2,%eax
801009f1:	01 d0                	add    %edx,%eax
801009f3:	c1 e0 04             	shl    $0x4,%eax
801009f6:	29 c1                	sub    %eax,%ecx
801009f8:	89 ca                	mov    %ecx,%edx
801009fa:	8d 42 fe             	lea    -0x2(%edx),%eax
801009fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
       pos -= todelete;
80100a00:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100a03:	29 45 f4             	sub    %eax,-0xc(%ebp)
       int counter =0;
80100a06:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
       while(counter < todelete){
80100a0d:	eb 23                	jmp    80100a32 <cgaputc+0x33e>
	 crt[pos + todelete - counter -1]=' ' | 0x0700;
80100a0f:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a14:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100a17:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100a1a:	01 ca                	add    %ecx,%edx
80100a1c:	2b 55 e8             	sub    -0x18(%ebp),%edx
80100a1f:	81 c2 ff ff ff 7f    	add    $0x7fffffff,%edx
80100a25:	01 d2                	add    %edx,%edx
80100a27:	01 d0                	add    %edx,%eax
80100a29:	66 c7 00 20 07       	movw   $0x720,(%eax)
	 counter++;
80100a2e:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
   }
   else{
     int todelete = pos%80 -2;
       pos -= todelete;
       int counter =0;
       while(counter < todelete){
80100a32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100a35:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
80100a38:	7c d5                	jl     80100a0f <cgaputc+0x31b>
80100a3a:	eb 57                	jmp    80100a93 <cgaputc+0x39f>
	 counter++;
       }
   }
  }
  else{
    memmove(crt + pos + 1, crt+pos, sizeof(crt[0])*23*80 - pos);
80100a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a3f:	ba 60 0e 00 00       	mov    $0xe60,%edx
80100a44:	89 d1                	mov    %edx,%ecx
80100a46:	29 c1                	sub    %eax,%ecx
80100a48:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a50:	01 d2                	add    %edx,%edx
80100a52:	01 c2                	add    %eax,%edx
80100a54:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a59:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80100a5c:	83 c3 01             	add    $0x1,%ebx
80100a5f:	01 db                	add    %ebx,%ebx
80100a61:	01 d8                	add    %ebx,%eax
80100a63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80100a67:	89 54 24 04          	mov    %edx,0x4(%esp)
80100a6b:	89 04 24             	mov    %eax,(%esp)
80100a6e:	e8 8a 50 00 00       	call   80105afd <memmove>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100a73:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
80100a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a7c:	8d 50 01             	lea    0x1(%eax),%edx
80100a7f:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100a82:	01 c0                	add    %eax,%eax
80100a84:	8d 14 01             	lea    (%ecx,%eax,1),%edx
80100a87:	8b 45 08             	mov    0x8(%ebp),%eax
80100a8a:	0f b6 c0             	movzbl %al,%eax
80100a8d:	80 cc 07             	or     $0x7,%ah
80100a90:	66 89 02             	mov    %ax,(%edx)
  }
    

  if(pos < 0 || pos > 25*80)
80100a93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a97:	78 09                	js     80100aa2 <cgaputc+0x3ae>
80100a99:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100aa0:	7e 0c                	jle    80100aae <cgaputc+0x3ba>
    panic("pos under/overflow");
80100aa2:	c7 04 24 2b 8f 10 80 	movl   $0x80108f2b,(%esp)
80100aa9:	e8 8c fa ff ff       	call   8010053a <panic>
  
  if((pos/80) >= 24){  // Scroll up.
80100aae:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100ab5:	7e 53                	jle    80100b0a <cgaputc+0x416>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100ab7:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100abc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100ac2:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100ac7:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
80100ace:	00 
80100acf:	89 54 24 04          	mov    %edx,0x4(%esp)
80100ad3:	89 04 24             	mov    %eax,(%esp)
80100ad6:	e8 22 50 00 00       	call   80105afd <memmove>
    pos -= 80;
80100adb:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100adf:	b8 80 07 00 00       	mov    $0x780,%eax
80100ae4:	2b 45 f4             	sub    -0xc(%ebp),%eax
80100ae7:	8d 14 00             	lea    (%eax,%eax,1),%edx
80100aea:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100aef:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100af2:	01 c9                	add    %ecx,%ecx
80100af4:	01 c8                	add    %ecx,%eax
80100af6:	89 54 24 08          	mov    %edx,0x8(%esp)
80100afa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100b01:	00 
80100b02:	89 04 24             	mov    %eax,(%esp)
80100b05:	e8 24 4f 00 00       	call   80105a2e <memset>
  }
  
  outb(CRTPORT, 14);
80100b0a:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100b11:	00 
80100b12:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100b19:	e8 af f7 ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
80100b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b21:	c1 f8 08             	sar    $0x8,%eax
80100b24:	0f b6 c0             	movzbl %al,%eax
80100b27:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b2b:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100b32:	e8 96 f7 ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
80100b37:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100b3e:	00 
80100b3f:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100b46:	e8 82 f7 ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b4e:	0f b6 c0             	movzbl %al,%eax
80100b51:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b55:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100b5c:	e8 6c f7 ff ff       	call   801002cd <outb>
  //crt[pos] = ' ' | 0x0700; //removed so there won't be a white space
}
80100b61:	83 c4 44             	add    $0x44,%esp
80100b64:	5b                   	pop    %ebx
80100b65:	5d                   	pop    %ebp
80100b66:	c3                   	ret    

80100b67 <consputc>:

void
consputc(int c)
{
80100b67:	55                   	push   %ebp
80100b68:	89 e5                	mov    %esp,%ebp
80100b6a:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100b6d:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
80100b72:	85 c0                	test   %eax,%eax
80100b74:	74 07                	je     80100b7d <consputc+0x16>
    cli();
80100b76:	e8 70 f7 ff ff       	call   801002eb <cli>
    for(;;)
      ;
80100b7b:	eb fe                	jmp    80100b7b <consputc+0x14>
  }
  
  if(c == BACKSPACE){
80100b7d:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100b84:	75 26                	jne    80100bac <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100b86:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100b8d:	e8 8e 69 00 00       	call   80107520 <uartputc>
80100b92:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100b99:	e8 82 69 00 00       	call   80107520 <uartputc>
80100b9e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100ba5:	e8 76 69 00 00       	call   80107520 <uartputc>
80100baa:	eb 0b                	jmp    80100bb7 <consputc+0x50>
  }
  else
    uartputc(c);
80100bac:	8b 45 08             	mov    0x8(%ebp),%eax
80100baf:	89 04 24             	mov    %eax,(%esp)
80100bb2:	e8 69 69 00 00       	call   80107520 <uartputc>
  cgaputc(c);
80100bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80100bba:	89 04 24             	mov    %eax,(%esp)
80100bbd:	e8 32 fb ff ff       	call   801006f4 <cgaputc>
}
80100bc2:	c9                   	leave  
80100bc3:	c3                   	ret    

80100bc4 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100bc4:	55                   	push   %ebp
80100bc5:	89 e5                	mov    %esp,%ebp
80100bc7:	53                   	push   %ebx
80100bc8:	83 ec 24             	sub    $0x24,%esp
  int c, doprocdump = 0;
80100bcb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  //int counter=0;
  acquire(&cons.lock);
80100bd2:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100bd9:	e8 fc 4b 00 00       	call   801057da <acquire>
  while((c = getc()) >= 0){
80100bde:	e9 6a 04 00 00       	jmp    8010104d <consoleintr+0x489>
    switch(c){
80100be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100be6:	83 f8 7f             	cmp    $0x7f,%eax
80100be9:	0f 84 b9 00 00 00    	je     80100ca8 <consoleintr+0xe4>
80100bef:	83 f8 7f             	cmp    $0x7f,%eax
80100bf2:	7f 18                	jg     80100c0c <consoleintr+0x48>
80100bf4:	83 f8 10             	cmp    $0x10,%eax
80100bf7:	74 50                	je     80100c49 <consoleintr+0x85>
80100bf9:	83 f8 15             	cmp    $0x15,%eax
80100bfc:	74 7f                	je     80100c7d <consoleintr+0xb9>
80100bfe:	83 f8 08             	cmp    $0x8,%eax
80100c01:	0f 84 a1 00 00 00    	je     80100ca8 <consoleintr+0xe4>
80100c07:	e9 13 03 00 00       	jmp    80100f1f <consoleintr+0x35b>
80100c0c:	3d e3 00 00 00       	cmp    $0xe3,%eax
80100c11:	0f 84 2b 02 00 00    	je     80100e42 <consoleintr+0x27e>
80100c17:	3d e3 00 00 00       	cmp    $0xe3,%eax
80100c1c:	7f 10                	jg     80100c2e <consoleintr+0x6a>
80100c1e:	3d e2 00 00 00       	cmp    $0xe2,%eax
80100c23:	0f 84 5e 01 00 00    	je     80100d87 <consoleintr+0x1c3>
80100c29:	e9 f1 02 00 00       	jmp    80100f1f <consoleintr+0x35b>
80100c2e:	3d e4 00 00 00       	cmp    $0xe4,%eax
80100c33:	0f 84 ea 00 00 00    	je     80100d23 <consoleintr+0x15f>
80100c39:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100c3e:	0f 84 11 01 00 00    	je     80100d55 <consoleintr+0x191>
80100c44:	e9 d6 02 00 00       	jmp    80100f1f <consoleintr+0x35b>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100c49:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100c50:	e9 f8 03 00 00       	jmp    8010104d <consoleintr+0x489>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.c--;
80100c55:	a1 2c 20 11 80       	mov    0x8011202c,%eax
80100c5a:	83 e8 01             	sub    $0x1,%eax
80100c5d:	a3 2c 20 11 80       	mov    %eax,0x8011202c
        input.e--;
80100c62:	a1 28 20 11 80       	mov    0x80112028,%eax
80100c67:	83 e8 01             	sub    $0x1,%eax
80100c6a:	a3 28 20 11 80       	mov    %eax,0x80112028
        consputc(BACKSPACE);
80100c6f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100c76:	e8 ec fe ff ff       	call   80100b67 <consputc>
80100c7b:	eb 01                	jmp    80100c7e <consoleintr+0xba>
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100c7d:	90                   	nop
80100c7e:	8b 15 28 20 11 80    	mov    0x80112028,%edx
80100c84:	a1 24 20 11 80       	mov    0x80112024,%eax
80100c89:	39 c2                	cmp    %eax,%edx
80100c8b:	74 16                	je     80100ca3 <consoleintr+0xdf>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100c8d:	a1 28 20 11 80       	mov    0x80112028,%eax
80100c92:	83 e8 01             	sub    $0x1,%eax
80100c95:	83 e0 7f             	and    $0x7f,%eax
80100c98:	0f b6 80 a0 1f 11 80 	movzbl -0x7feee060(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100c9f:	3c 0a                	cmp    $0xa,%al
80100ca1:	75 b2                	jne    80100c55 <consoleintr+0x91>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.c--;
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100ca3:	e9 a5 03 00 00       	jmp    8010104d <consoleintr+0x489>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100ca8:	8b 15 28 20 11 80    	mov    0x80112028,%edx
80100cae:	a1 24 20 11 80       	mov    0x80112024,%eax
80100cb3:	39 c2                	cmp    %eax,%edx
80100cb5:	74 67                	je     80100d1e <consoleintr+0x15a>
        input.e--;
80100cb7:	a1 28 20 11 80       	mov    0x80112028,%eax
80100cbc:	83 e8 01             	sub    $0x1,%eax
80100cbf:	a3 28 20 11 80       	mov    %eax,0x80112028
	input.c--;
80100cc4:	a1 2c 20 11 80       	mov    0x8011202c,%eax
80100cc9:	83 e8 01             	sub    $0x1,%eax
80100ccc:	a3 2c 20 11 80       	mov    %eax,0x8011202c
	memmove(input.buf + (input.c % INPUT_BUF), input.buf + (input.c % INPUT_BUF) + 1, INPUT_BUF - input.c);
80100cd1:	a1 2c 20 11 80       	mov    0x8011202c,%eax
80100cd6:	ba 80 00 00 00       	mov    $0x80,%edx
80100cdb:	89 d1                	mov    %edx,%ecx
80100cdd:	29 c1                	sub    %eax,%ecx
80100cdf:	a1 2c 20 11 80       	mov    0x8011202c,%eax
80100ce4:	83 e0 7f             	and    $0x7f,%eax
80100ce7:	83 c0 01             	add    $0x1,%eax
80100cea:	8d 90 a0 1f 11 80    	lea    -0x7feee060(%eax),%edx
80100cf0:	a1 2c 20 11 80       	mov    0x8011202c,%eax
80100cf5:	83 e0 7f             	and    $0x7f,%eax
80100cf8:	05 a0 1f 11 80       	add    $0x80111fa0,%eax
80100cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80100d01:	89 54 24 04          	mov    %edx,0x4(%esp)
80100d05:	89 04 24             	mov    %eax,(%esp)
80100d08:	e8 f0 4d 00 00       	call   80105afd <memmove>
        consputc(BACKSPACE);
80100d0d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100d14:	e8 4e fe ff ff       	call   80100b67 <consputc>
      }
      break;
80100d19:	e9 2f 03 00 00       	jmp    8010104d <consoleintr+0x489>
80100d1e:	e9 2a 03 00 00       	jmp    8010104d <consoleintr+0x489>
    case LEFT_ARROW:
      if(input.c > input.w){
80100d23:	8b 15 2c 20 11 80    	mov    0x8011202c,%edx
80100d29:	a1 24 20 11 80       	mov    0x80112024,%eax
80100d2e:	39 c2                	cmp    %eax,%edx
80100d30:	76 1e                	jbe    80100d50 <consoleintr+0x18c>
        input.c--;
80100d32:	a1 2c 20 11 80       	mov    0x8011202c,%eax
80100d37:	83 e8 01             	sub    $0x1,%eax
80100d3a:	a3 2c 20 11 80       	mov    %eax,0x8011202c
	consputc(LEFT_ARROW);
80100d3f:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100d46:	e8 1c fe ff ff       	call   80100b67 <consputc>
      }
      break;   
80100d4b:	e9 fd 02 00 00       	jmp    8010104d <consoleintr+0x489>
80100d50:	e9 f8 02 00 00       	jmp    8010104d <consoleintr+0x489>
      
    case RIGHT_ARROW:
      if(input.c < input.e){
80100d55:	8b 15 2c 20 11 80    	mov    0x8011202c,%edx
80100d5b:	a1 28 20 11 80       	mov    0x80112028,%eax
80100d60:	39 c2                	cmp    %eax,%edx
80100d62:	73 1e                	jae    80100d82 <consoleintr+0x1be>
        input.c++;
80100d64:	a1 2c 20 11 80       	mov    0x8011202c,%eax
80100d69:	83 c0 01             	add    $0x1,%eax
80100d6c:	a3 2c 20 11 80       	mov    %eax,0x8011202c
	consputc(RIGHT_ARROW);
80100d71:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100d78:	e8 ea fd ff ff       	call   80100b67 <consputc>
      }
      break;
80100d7d:	e9 cb 02 00 00       	jmp    8010104d <consoleintr+0x489>
80100d82:	e9 c6 02 00 00       	jmp    8010104d <consoleintr+0x489>
     case UP_ARROW:
       if(inputHistory.current < inputHistory.size - 1 && inputHistory.size > 0){  
80100d87:	a1 80 17 11 80       	mov    0x80111780,%eax
80100d8c:	8b 15 84 17 11 80    	mov    0x80111784,%edx
80100d92:	83 ea 01             	sub    $0x1,%edx
80100d95:	39 d0                	cmp    %edx,%eax
80100d97:	0f 8d a0 00 00 00    	jge    80100e3d <consoleintr+0x279>
80100d9d:	a1 84 17 11 80       	mov    0x80111784,%eax
80100da2:	85 c0                	test   %eax,%eax
80100da4:	0f 8e 93 00 00 00    	jle    80100e3d <consoleintr+0x279>
	    inputHistory.current++;
80100daa:	a1 80 17 11 80       	mov    0x80111780,%eax
80100daf:	83 c0 01             	add    $0x1,%eax
80100db2:	a3 80 17 11 80       	mov    %eax,0x80111780
	    memmove(input.buf + input.r , inputHistory.buf[inputHistory.current], history_get_string_size(inputHistory.buf[inputHistory.current]));
80100db7:	a1 80 17 11 80       	mov    0x80111780,%eax
80100dbc:	c1 e0 07             	shl    $0x7,%eax
80100dbf:	05 80 17 11 80       	add    $0x80111780,%eax
80100dc4:	83 c0 08             	add    $0x8,%eax
80100dc7:	89 04 24             	mov    %eax,(%esp)
80100dca:	e8 89 f8 ff ff       	call   80100658 <history_get_string_size>
80100dcf:	8b 15 80 17 11 80    	mov    0x80111780,%edx
80100dd5:	c1 e2 07             	shl    $0x7,%edx
80100dd8:	81 c2 80 17 11 80    	add    $0x80111780,%edx
80100dde:	8d 4a 08             	lea    0x8(%edx),%ecx
80100de1:	8b 15 20 20 11 80    	mov    0x80112020,%edx
80100de7:	81 c2 a0 1f 11 80    	add    $0x80111fa0,%edx
80100ded:	89 44 24 08          	mov    %eax,0x8(%esp)
80100df1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80100df5:	89 14 24             	mov    %edx,(%esp)
80100df8:	e8 00 4d 00 00       	call   80105afd <memmove>
	    input.e = input.r + history_get_string_size(inputHistory.buf[inputHistory.current]);
80100dfd:	8b 1d 20 20 11 80    	mov    0x80112020,%ebx
80100e03:	a1 80 17 11 80       	mov    0x80111780,%eax
80100e08:	c1 e0 07             	shl    $0x7,%eax
80100e0b:	05 80 17 11 80       	add    $0x80111780,%eax
80100e10:	83 c0 08             	add    $0x8,%eax
80100e13:	89 04 24             	mov    %eax,(%esp)
80100e16:	e8 3d f8 ff ff       	call   80100658 <history_get_string_size>
80100e1b:	01 d8                	add    %ebx,%eax
80100e1d:	a3 28 20 11 80       	mov    %eax,0x80112028
	    input.c = input.e;
80100e22:	a1 28 20 11 80       	mov    0x80112028,%eax
80100e27:	a3 2c 20 11 80       	mov    %eax,0x8011202c
	    consputc(UP_ARROW);
80100e2c:	c7 04 24 e2 00 00 00 	movl   $0xe2,(%esp)
80100e33:	e8 2f fd ff ff       	call   80100b67 <consputc>

       }
      break;
80100e38:	e9 10 02 00 00       	jmp    8010104d <consoleintr+0x489>
80100e3d:	e9 0b 02 00 00       	jmp    8010104d <consoleintr+0x489>
      case DOWN_ARROW:
	if(inputHistory.current > 0){  
80100e42:	a1 80 17 11 80       	mov    0x80111780,%eax
80100e47:	85 c0                	test   %eax,%eax
80100e49:	0f 8e 90 00 00 00    	jle    80100edf <consoleintr+0x31b>
	    inputHistory.current--;
80100e4f:	a1 80 17 11 80       	mov    0x80111780,%eax
80100e54:	83 e8 01             	sub    $0x1,%eax
80100e57:	a3 80 17 11 80       	mov    %eax,0x80111780
	    memmove(input.buf + input.r , inputHistory.buf[inputHistory.current], history_get_string_size(inputHistory.buf[inputHistory.current]));
80100e5c:	a1 80 17 11 80       	mov    0x80111780,%eax
80100e61:	c1 e0 07             	shl    $0x7,%eax
80100e64:	05 80 17 11 80       	add    $0x80111780,%eax
80100e69:	83 c0 08             	add    $0x8,%eax
80100e6c:	89 04 24             	mov    %eax,(%esp)
80100e6f:	e8 e4 f7 ff ff       	call   80100658 <history_get_string_size>
80100e74:	8b 15 80 17 11 80    	mov    0x80111780,%edx
80100e7a:	c1 e2 07             	shl    $0x7,%edx
80100e7d:	81 c2 80 17 11 80    	add    $0x80111780,%edx
80100e83:	8d 4a 08             	lea    0x8(%edx),%ecx
80100e86:	8b 15 20 20 11 80    	mov    0x80112020,%edx
80100e8c:	81 c2 a0 1f 11 80    	add    $0x80111fa0,%edx
80100e92:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e96:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80100e9a:	89 14 24             	mov    %edx,(%esp)
80100e9d:	e8 5b 4c 00 00       	call   80105afd <memmove>
	    input.e = input.r + history_get_string_size(inputHistory.buf[inputHistory.current]);
80100ea2:	8b 1d 20 20 11 80    	mov    0x80112020,%ebx
80100ea8:	a1 80 17 11 80       	mov    0x80111780,%eax
80100ead:	c1 e0 07             	shl    $0x7,%eax
80100eb0:	05 80 17 11 80       	add    $0x80111780,%eax
80100eb5:	83 c0 08             	add    $0x8,%eax
80100eb8:	89 04 24             	mov    %eax,(%esp)
80100ebb:	e8 98 f7 ff ff       	call   80100658 <history_get_string_size>
80100ec0:	01 d8                	add    %ebx,%eax
80100ec2:	a3 28 20 11 80       	mov    %eax,0x80112028
	    input.c = input.e;
80100ec7:	a1 28 20 11 80       	mov    0x80112028,%eax
80100ecc:	a3 2c 20 11 80       	mov    %eax,0x8011202c
	    consputc(DOWN_ARROW);
80100ed1:	c7 04 24 e3 00 00 00 	movl   $0xe3,(%esp)
80100ed8:	e8 8a fc ff ff       	call   80100b67 <consputc>
80100edd:	eb 3b                	jmp    80100f1a <consoleintr+0x356>

	}   
	else if(inputHistory.current == 0){  
80100edf:	a1 80 17 11 80       	mov    0x80111780,%eax
80100ee4:	85 c0                	test   %eax,%eax
80100ee6:	75 32                	jne    80100f1a <consoleintr+0x356>
	    inputHistory.current--;
80100ee8:	a1 80 17 11 80       	mov    0x80111780,%eax
80100eed:	83 e8 01             	sub    $0x1,%eax
80100ef0:	a3 80 17 11 80       	mov    %eax,0x80111780
	    input.e = input.r ;
80100ef5:	a1 20 20 11 80       	mov    0x80112020,%eax
80100efa:	a3 28 20 11 80       	mov    %eax,0x80112028
	    input.c = input.e;
80100eff:	a1 28 20 11 80       	mov    0x80112028,%eax
80100f04:	a3 2c 20 11 80       	mov    %eax,0x8011202c
	    consputc(DOWN_ARROW);
80100f09:	c7 04 24 e3 00 00 00 	movl   $0xe3,(%esp)
80100f10:	e8 52 fc ff ff       	call   80100b67 <consputc>
	}   
	break;
80100f15:	e9 33 01 00 00       	jmp    8010104d <consoleintr+0x489>
80100f1a:	e9 2e 01 00 00       	jmp    8010104d <consoleintr+0x489>
      
      
      
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100f1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100f23:	0f 84 23 01 00 00    	je     8010104c <consoleintr+0x488>
80100f29:	8b 15 28 20 11 80    	mov    0x80112028,%edx
80100f2f:	a1 20 20 11 80       	mov    0x80112020,%eax
80100f34:	29 c2                	sub    %eax,%edx
80100f36:	89 d0                	mov    %edx,%eax
80100f38:	83 f8 7f             	cmp    $0x7f,%eax
80100f3b:	0f 87 0b 01 00 00    	ja     8010104c <consoleintr+0x488>
        c = (c == '\r') ? '\n' : c;
80100f41:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100f45:	74 05                	je     80100f4c <consoleintr+0x388>
80100f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100f4a:	eb 05                	jmp    80100f51 <consoleintr+0x38d>
80100f4c:	b8 0a 00 00 00       	mov    $0xa,%eax
80100f51:	89 45 f0             	mov    %eax,-0x10(%ebp)
	inputHistory.current = -1;
80100f54:	c7 05 80 17 11 80 ff 	movl   $0xffffffff,0x80111780
80100f5b:	ff ff ff 
	if(c == '\n'){
80100f5e:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100f62:	75 1e                	jne    80100f82 <consoleintr+0x3be>
	  input.buf[input.e++ % INPUT_BUF] = c;
80100f64:	a1 28 20 11 80       	mov    0x80112028,%eax
80100f69:	8d 50 01             	lea    0x1(%eax),%edx
80100f6c:	89 15 28 20 11 80    	mov    %edx,0x80112028
80100f72:	83 e0 7f             	and    $0x7f,%eax
80100f75:	89 c2                	mov    %eax,%edx
80100f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100f7a:	88 82 a0 1f 11 80    	mov    %al,-0x7feee060(%edx)
80100f80:	eb 65                	jmp    80100fe7 <consoleintr+0x423>
	}else{
	  memmove(input.buf + (input.c % INPUT_BUF) + 1, input.buf + (input.c % INPUT_BUF), INPUT_BUF - input.c - 1);
80100f82:	a1 2c 20 11 80       	mov    0x8011202c,%eax
80100f87:	ba 7f 00 00 00       	mov    $0x7f,%edx
80100f8c:	89 d1                	mov    %edx,%ecx
80100f8e:	29 c1                	sub    %eax,%ecx
80100f90:	a1 2c 20 11 80       	mov    0x8011202c,%eax
80100f95:	83 e0 7f             	and    $0x7f,%eax
80100f98:	8d 90 a0 1f 11 80    	lea    -0x7feee060(%eax),%edx
80100f9e:	a1 2c 20 11 80       	mov    0x8011202c,%eax
80100fa3:	83 e0 7f             	and    $0x7f,%eax
80100fa6:	83 c0 01             	add    $0x1,%eax
80100fa9:	05 a0 1f 11 80       	add    $0x80111fa0,%eax
80100fae:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80100fb2:	89 54 24 04          	mov    %edx,0x4(%esp)
80100fb6:	89 04 24             	mov    %eax,(%esp)
80100fb9:	e8 3f 4b 00 00       	call   80105afd <memmove>
	  input.buf[input.c++ % INPUT_BUF] = c;
80100fbe:	a1 2c 20 11 80       	mov    0x8011202c,%eax
80100fc3:	8d 50 01             	lea    0x1(%eax),%edx
80100fc6:	89 15 2c 20 11 80    	mov    %edx,0x8011202c
80100fcc:	83 e0 7f             	and    $0x7f,%eax
80100fcf:	89 c2                	mov    %eax,%edx
80100fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100fd4:	88 82 a0 1f 11 80    	mov    %al,-0x7feee060(%edx)
	  input.e++;
80100fda:	a1 28 20 11 80       	mov    0x80112028,%eax
80100fdf:	83 c0 01             	add    $0x1,%eax
80100fe2:	a3 28 20 11 80       	mov    %eax,0x80112028
	}
        consputc(c);
80100fe7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100fea:	89 04 24             	mov    %eax,(%esp)
80100fed:	e8 75 fb ff ff       	call   80100b67 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100ff2:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100ff6:	74 18                	je     80101010 <consoleintr+0x44c>
80100ff8:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100ffc:	74 12                	je     80101010 <consoleintr+0x44c>
80100ffe:	a1 28 20 11 80       	mov    0x80112028,%eax
80101003:	8b 15 20 20 11 80    	mov    0x80112020,%edx
80101009:	83 ea 80             	sub    $0xffffff80,%edx
8010100c:	39 d0                	cmp    %edx,%eax
8010100e:	75 3c                	jne    8010104c <consoleintr+0x488>
	  history_insert(&inputHistory,input.buf+input.r);
80101010:	a1 20 20 11 80       	mov    0x80112020,%eax
80101015:	05 a0 1f 11 80       	add    $0x80111fa0,%eax
8010101a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010101e:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80101025:	e8 a0 f5 ff ff       	call   801005ca <history_insert>
          input.w = input.e;
8010102a:	a1 28 20 11 80       	mov    0x80112028,%eax
8010102f:	a3 24 20 11 80       	mov    %eax,0x80112024
	  input.c = input.e;
80101034:	a1 28 20 11 80       	mov    0x80112028,%eax
80101039:	a3 2c 20 11 80       	mov    %eax,0x8011202c
          wakeup(&input.r);
8010103e:	c7 04 24 20 20 11 80 	movl   $0x80112020,(%esp)
80101045:	e8 1d 45 00 00       	call   80105567 <wakeup>
        }
      }
      break;
8010104a:	eb 00                	jmp    8010104c <consoleintr+0x488>
8010104c:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;
  //int counter=0;
  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010104d:	8b 45 08             	mov    0x8(%ebp),%eax
80101050:	ff d0                	call   *%eax
80101052:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101055:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101059:	0f 89 84 fb ff ff    	jns    80100be3 <consoleintr+0x1f>
        }
      }
      break;
    }
  }
  release(&cons.lock);
8010105f:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80101066:	e8 d1 47 00 00       	call   8010583c <release>
  if(doprocdump) {
8010106b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010106f:	74 05                	je     80101076 <consoleintr+0x4b2>
    procdump();  // now call procdump() wo. cons.lock held
80101071:	e8 97 45 00 00       	call   8010560d <procdump>
  }
}
80101076:	83 c4 24             	add    $0x24,%esp
80101079:	5b                   	pop    %ebx
8010107a:	5d                   	pop    %ebp
8010107b:	c3                   	ret    

8010107c <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010107c:	55                   	push   %ebp
8010107d:	89 e5                	mov    %esp,%ebp
8010107f:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80101082:	8b 45 08             	mov    0x8(%ebp),%eax
80101085:	89 04 24             	mov    %eax,(%esp)
80101088:	e8 e1 10 00 00       	call   8010216e <iunlock>
  target = n;
8010108d:	8b 45 10             	mov    0x10(%ebp),%eax
80101090:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80101093:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
8010109a:	e8 3b 47 00 00       	call   801057da <acquire>
  while(n > 0){
8010109f:	e9 aa 00 00 00       	jmp    8010114e <consoleread+0xd2>
    while(input.r == input.w){
801010a4:	eb 42                	jmp    801010e8 <consoleread+0x6c>
      if(proc->killed){
801010a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801010ac:	8b 40 24             	mov    0x24(%eax),%eax
801010af:	85 c0                	test   %eax,%eax
801010b1:	74 21                	je     801010d4 <consoleread+0x58>
        release(&cons.lock);
801010b3:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801010ba:	e8 7d 47 00 00       	call   8010583c <release>
        ilock(ip);
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	89 04 24             	mov    %eax,(%esp)
801010c5:	e8 50 0f 00 00       	call   8010201a <ilock>
        return -1;
801010ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801010cf:	e9 a5 00 00 00       	jmp    80101179 <consoleread+0xfd>
      }
      sleep(&input.r, &cons.lock);
801010d4:	c7 44 24 04 c0 c5 10 	movl   $0x8010c5c0,0x4(%esp)
801010db:	80 
801010dc:	c7 04 24 20 20 11 80 	movl   $0x80112020,(%esp)
801010e3:	e8 a3 43 00 00       	call   8010548b <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801010e8:	8b 15 20 20 11 80    	mov    0x80112020,%edx
801010ee:	a1 24 20 11 80       	mov    0x80112024,%eax
801010f3:	39 c2                	cmp    %eax,%edx
801010f5:	74 af                	je     801010a6 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801010f7:	a1 20 20 11 80       	mov    0x80112020,%eax
801010fc:	8d 50 01             	lea    0x1(%eax),%edx
801010ff:	89 15 20 20 11 80    	mov    %edx,0x80112020
80101105:	83 e0 7f             	and    $0x7f,%eax
80101108:	0f b6 80 a0 1f 11 80 	movzbl -0x7feee060(%eax),%eax
8010110f:	0f be c0             	movsbl %al,%eax
80101112:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80101115:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80101119:	75 19                	jne    80101134 <consoleread+0xb8>
      if(n < target){
8010111b:	8b 45 10             	mov    0x10(%ebp),%eax
8010111e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80101121:	73 0f                	jae    80101132 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80101123:	a1 20 20 11 80       	mov    0x80112020,%eax
80101128:	83 e8 01             	sub    $0x1,%eax
8010112b:	a3 20 20 11 80       	mov    %eax,0x80112020
      }
      break;
80101130:	eb 26                	jmp    80101158 <consoleread+0xdc>
80101132:	eb 24                	jmp    80101158 <consoleread+0xdc>
    }
    
    *dst++ = c;
80101134:	8b 45 0c             	mov    0xc(%ebp),%eax
80101137:	8d 50 01             	lea    0x1(%eax),%edx
8010113a:	89 55 0c             	mov    %edx,0xc(%ebp)
8010113d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101140:	88 10                	mov    %dl,(%eax)
    --n;
80101142:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80101146:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010114a:	75 02                	jne    8010114e <consoleread+0xd2>
      break;
8010114c:	eb 0a                	jmp    80101158 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
8010114e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101152:	0f 8f 4c ff ff ff    	jg     801010a4 <consoleread+0x28>
    --n;
    if(c == '\n')
      break;
    
  }
  release(&cons.lock);
80101158:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
8010115f:	e8 d8 46 00 00       	call   8010583c <release>
  ilock(ip);
80101164:	8b 45 08             	mov    0x8(%ebp),%eax
80101167:	89 04 24             	mov    %eax,(%esp)
8010116a:	e8 ab 0e 00 00       	call   8010201a <ilock>

  return target - n;
8010116f:	8b 45 10             	mov    0x10(%ebp),%eax
80101172:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101175:	29 c2                	sub    %eax,%edx
80101177:	89 d0                	mov    %edx,%eax
}
80101179:	c9                   	leave  
8010117a:	c3                   	ret    

8010117b <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
8010117b:	55                   	push   %ebp
8010117c:	89 e5                	mov    %esp,%ebp
8010117e:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80101181:	8b 45 08             	mov    0x8(%ebp),%eax
80101184:	89 04 24             	mov    %eax,(%esp)
80101187:	e8 e2 0f 00 00       	call   8010216e <iunlock>
  acquire(&cons.lock);
8010118c:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80101193:	e8 42 46 00 00       	call   801057da <acquire>
  for(i = 0; i < n; i++)
80101198:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010119f:	eb 1d                	jmp    801011be <consolewrite+0x43>
    consputc(buf[i] & 0xff);
801011a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801011a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801011a7:	01 d0                	add    %edx,%eax
801011a9:	0f b6 00             	movzbl (%eax),%eax
801011ac:	0f be c0             	movsbl %al,%eax
801011af:	0f b6 c0             	movzbl %al,%eax
801011b2:	89 04 24             	mov    %eax,(%esp)
801011b5:	e8 ad f9 ff ff       	call   80100b67 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
801011ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801011be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011c1:	3b 45 10             	cmp    0x10(%ebp),%eax
801011c4:	7c db                	jl     801011a1 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
801011c6:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801011cd:	e8 6a 46 00 00       	call   8010583c <release>
  ilock(ip);
801011d2:	8b 45 08             	mov    0x8(%ebp),%eax
801011d5:	89 04 24             	mov    %eax,(%esp)
801011d8:	e8 3d 0e 00 00       	call   8010201a <ilock>

  return n;
801011dd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801011e0:	c9                   	leave  
801011e1:	c3                   	ret    

801011e2 <consoleinit>:

void
consoleinit(void)
{
801011e2:	55                   	push   %ebp
801011e3:	89 e5                	mov    %esp,%ebp
801011e5:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
801011e8:	c7 44 24 04 3e 8f 10 	movl   $0x80108f3e,0x4(%esp)
801011ef:	80 
801011f0:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801011f7:	e8 bd 45 00 00       	call   801057b9 <initlock>

  devsw[CONSOLE].write = consolewrite;
801011fc:	c7 05 ec 29 11 80 7b 	movl   $0x8010117b,0x801129ec
80101203:	11 10 80 
  devsw[CONSOLE].read = consoleread;
80101206:	c7 05 e8 29 11 80 7c 	movl   $0x8010107c,0x801129e8
8010120d:	10 10 80 
  cons.locking = 1;
80101210:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80101217:	00 00 00 

  picenable(IRQ_KBD);
8010121a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80101221:	e8 7b 33 00 00       	call   801045a1 <picenable>
  ioapicenable(IRQ_KBD, 0);
80101226:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010122d:	00 
8010122e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80101235:	e8 1f 1f 00 00       	call   80103159 <ioapicenable>
  
  inputHistory.size = 0;
8010123a:	c7 05 84 17 11 80 00 	movl   $0x0,0x80111784
80101241:	00 00 00 
  inputHistory.current = -1;
80101244:	c7 05 80 17 11 80 ff 	movl   $0xffffffff,0x80111780
8010124b:	ff ff ff 
}
8010124e:	c9                   	leave  
8010124f:	c3                   	ret    

80101250 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80101250:	55                   	push   %ebp
80101251:	89 e5                	mov    %esp,%ebp
80101253:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80101259:	e8 a4 29 00 00       	call   80103c02 <begin_op>
  if((ip = namei(path)) == 0){
8010125e:	8b 45 08             	mov    0x8(%ebp),%eax
80101261:	89 04 24             	mov    %eax,(%esp)
80101264:	e8 62 19 00 00       	call   80102bcb <namei>
80101269:	89 45 d8             	mov    %eax,-0x28(%ebp)
8010126c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101270:	75 0f                	jne    80101281 <exec+0x31>
    end_op();
80101272:	e8 0f 2a 00 00       	call   80103c86 <end_op>
    return -1;
80101277:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010127c:	e9 e8 03 00 00       	jmp    80101669 <exec+0x419>
  }
  ilock(ip);
80101281:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101284:	89 04 24             	mov    %eax,(%esp)
80101287:	e8 8e 0d 00 00       	call   8010201a <ilock>
  pgdir = 0;
8010128c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80101293:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
8010129a:	00 
8010129b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801012a2:	00 
801012a3:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
801012a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801012ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
801012b0:	89 04 24             	mov    %eax,(%esp)
801012b3:	e8 75 12 00 00       	call   8010252d <readi>
801012b8:	83 f8 33             	cmp    $0x33,%eax
801012bb:	77 05                	ja     801012c2 <exec+0x72>
    goto bad;
801012bd:	e9 7b 03 00 00       	jmp    8010163d <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
801012c2:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
801012c8:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
801012cd:	74 05                	je     801012d4 <exec+0x84>
    goto bad;
801012cf:	e9 69 03 00 00       	jmp    8010163d <exec+0x3ed>

  if((pgdir = setupkvm()) == 0)
801012d4:	e8 98 73 00 00       	call   80108671 <setupkvm>
801012d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801012dc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801012e0:	75 05                	jne    801012e7 <exec+0x97>
    goto bad;
801012e2:	e9 56 03 00 00       	jmp    8010163d <exec+0x3ed>

  // Load program into memory.
  sz = 0;
801012e7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801012ee:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801012f5:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
801012fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012fe:	e9 cb 00 00 00       	jmp    801013ce <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80101303:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101306:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
8010130d:	00 
8010130e:	89 44 24 08          	mov    %eax,0x8(%esp)
80101312:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80101318:	89 44 24 04          	mov    %eax,0x4(%esp)
8010131c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010131f:	89 04 24             	mov    %eax,(%esp)
80101322:	e8 06 12 00 00       	call   8010252d <readi>
80101327:	83 f8 20             	cmp    $0x20,%eax
8010132a:	74 05                	je     80101331 <exec+0xe1>
      goto bad;
8010132c:	e9 0c 03 00 00       	jmp    8010163d <exec+0x3ed>
    if(ph.type != ELF_PROG_LOAD)
80101331:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80101337:	83 f8 01             	cmp    $0x1,%eax
8010133a:	74 05                	je     80101341 <exec+0xf1>
      continue;
8010133c:	e9 80 00 00 00       	jmp    801013c1 <exec+0x171>
    if(ph.memsz < ph.filesz)
80101341:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80101347:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
8010134d:	39 c2                	cmp    %eax,%edx
8010134f:	73 05                	jae    80101356 <exec+0x106>
      goto bad;
80101351:	e9 e7 02 00 00       	jmp    8010163d <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80101356:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
8010135c:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80101362:	01 d0                	add    %edx,%eax
80101364:	89 44 24 08          	mov    %eax,0x8(%esp)
80101368:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010136b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010136f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101372:	89 04 24             	mov    %eax,(%esp)
80101375:	e8 c5 76 00 00       	call   80108a3f <allocuvm>
8010137a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010137d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101381:	75 05                	jne    80101388 <exec+0x138>
      goto bad;
80101383:	e9 b5 02 00 00       	jmp    8010163d <exec+0x3ed>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80101388:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
8010138e:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80101394:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
8010139a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010139e:	89 54 24 0c          	mov    %edx,0xc(%esp)
801013a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
801013a5:	89 54 24 08          	mov    %edx,0x8(%esp)
801013a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801013ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801013b0:	89 04 24             	mov    %eax,(%esp)
801013b3:	e8 9c 75 00 00       	call   80108954 <loaduvm>
801013b8:	85 c0                	test   %eax,%eax
801013ba:	79 05                	jns    801013c1 <exec+0x171>
      goto bad;
801013bc:	e9 7c 02 00 00       	jmp    8010163d <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801013c1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801013c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013c8:	83 c0 20             	add    $0x20,%eax
801013cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013ce:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
801013d5:	0f b7 c0             	movzwl %ax,%eax
801013d8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013db:	0f 8f 22 ff ff ff    	jg     80101303 <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
801013e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801013e4:	89 04 24             	mov    %eax,(%esp)
801013e7:	e8 b8 0e 00 00       	call   801022a4 <iunlockput>
  end_op();
801013ec:	e8 95 28 00 00       	call   80103c86 <end_op>
  ip = 0;
801013f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
801013f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013fb:	05 ff 0f 00 00       	add    $0xfff,%eax
80101400:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80101405:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80101408:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010140b:	05 00 20 00 00       	add    $0x2000,%eax
80101410:	89 44 24 08          	mov    %eax,0x8(%esp)
80101414:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101417:	89 44 24 04          	mov    %eax,0x4(%esp)
8010141b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010141e:	89 04 24             	mov    %eax,(%esp)
80101421:	e8 19 76 00 00       	call   80108a3f <allocuvm>
80101426:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101429:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010142d:	75 05                	jne    80101434 <exec+0x1e4>
    goto bad;
8010142f:	e9 09 02 00 00       	jmp    8010163d <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80101434:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101437:	2d 00 20 00 00       	sub    $0x2000,%eax
8010143c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101440:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101443:	89 04 24             	mov    %eax,(%esp)
80101446:	e8 24 78 00 00       	call   80108c6f <clearpteu>
  sp = sz;
8010144b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010144e:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101451:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101458:	e9 9a 00 00 00       	jmp    801014f7 <exec+0x2a7>
    if(argc >= MAXARG)
8010145d:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80101461:	76 05                	jbe    80101468 <exec+0x218>
      goto bad;
80101463:	e9 d5 01 00 00       	jmp    8010163d <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101468:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010146b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101472:	8b 45 0c             	mov    0xc(%ebp),%eax
80101475:	01 d0                	add    %edx,%eax
80101477:	8b 00                	mov    (%eax),%eax
80101479:	89 04 24             	mov    %eax,(%esp)
8010147c:	e8 17 48 00 00       	call   80105c98 <strlen>
80101481:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101484:	29 c2                	sub    %eax,%edx
80101486:	89 d0                	mov    %edx,%eax
80101488:	83 e8 01             	sub    $0x1,%eax
8010148b:	83 e0 fc             	and    $0xfffffffc,%eax
8010148e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101491:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101494:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010149b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010149e:	01 d0                	add    %edx,%eax
801014a0:	8b 00                	mov    (%eax),%eax
801014a2:	89 04 24             	mov    %eax,(%esp)
801014a5:	e8 ee 47 00 00       	call   80105c98 <strlen>
801014aa:	83 c0 01             	add    $0x1,%eax
801014ad:	89 c2                	mov    %eax,%edx
801014af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014b2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
801014b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801014bc:	01 c8                	add    %ecx,%eax
801014be:	8b 00                	mov    (%eax),%eax
801014c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
801014c4:	89 44 24 08          	mov    %eax,0x8(%esp)
801014c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801014cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801014cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801014d2:	89 04 24             	mov    %eax,(%esp)
801014d5:	e8 5a 79 00 00       	call   80108e34 <copyout>
801014da:	85 c0                	test   %eax,%eax
801014dc:	79 05                	jns    801014e3 <exec+0x293>
      goto bad;
801014de:	e9 5a 01 00 00       	jmp    8010163d <exec+0x3ed>
    ustack[3+argc] = sp;
801014e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014e6:	8d 50 03             	lea    0x3(%eax),%edx
801014e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801014ec:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
801014f3:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801014f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101501:	8b 45 0c             	mov    0xc(%ebp),%eax
80101504:	01 d0                	add    %edx,%eax
80101506:	8b 00                	mov    (%eax),%eax
80101508:	85 c0                	test   %eax,%eax
8010150a:	0f 85 4d ff ff ff    	jne    8010145d <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80101510:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101513:	83 c0 03             	add    $0x3,%eax
80101516:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
8010151d:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80101521:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80101528:	ff ff ff 
  ustack[1] = argc;
8010152b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010152e:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101537:	83 c0 01             	add    $0x1,%eax
8010153a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101541:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101544:	29 d0                	sub    %edx,%eax
80101546:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
8010154c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010154f:	83 c0 04             	add    $0x4,%eax
80101552:	c1 e0 02             	shl    $0x2,%eax
80101555:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80101558:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010155b:	83 c0 04             	add    $0x4,%eax
8010155e:	c1 e0 02             	shl    $0x2,%eax
80101561:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101565:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
8010156b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010156f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101572:	89 44 24 04          	mov    %eax,0x4(%esp)
80101576:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101579:	89 04 24             	mov    %eax,(%esp)
8010157c:	e8 b3 78 00 00       	call   80108e34 <copyout>
80101581:	85 c0                	test   %eax,%eax
80101583:	79 05                	jns    8010158a <exec+0x33a>
    goto bad;
80101585:	e9 b3 00 00 00       	jmp    8010163d <exec+0x3ed>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010158a:	8b 45 08             	mov    0x8(%ebp),%eax
8010158d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101593:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101596:	eb 17                	jmp    801015af <exec+0x35f>
    if(*s == '/')
80101598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159b:	0f b6 00             	movzbl (%eax),%eax
8010159e:	3c 2f                	cmp    $0x2f,%al
801015a0:	75 09                	jne    801015ab <exec+0x35b>
      last = s+1;
801015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a5:	83 c0 01             	add    $0x1,%eax
801015a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
801015ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801015af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015b2:	0f b6 00             	movzbl (%eax),%eax
801015b5:	84 c0                	test   %al,%al
801015b7:	75 df                	jne    80101598 <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
801015b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801015bf:	8d 50 6c             	lea    0x6c(%eax),%edx
801015c2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801015c9:	00 
801015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801015d1:	89 14 24             	mov    %edx,(%esp)
801015d4:	e8 75 46 00 00       	call   80105c4e <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
801015d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801015df:	8b 40 04             	mov    0x4(%eax),%eax
801015e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
801015e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801015eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801015ee:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801015f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801015f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801015fa:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801015fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101602:	8b 40 18             	mov    0x18(%eax),%eax
80101605:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
8010160b:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
8010160e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101614:	8b 40 18             	mov    0x18(%eax),%eax
80101617:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010161a:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
8010161d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101623:	89 04 24             	mov    %eax,(%esp)
80101626:	e8 37 71 00 00       	call   80108762 <switchuvm>
  freevm(oldpgdir);
8010162b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010162e:	89 04 24             	mov    %eax,(%esp)
80101631:	e8 9f 75 00 00       	call   80108bd5 <freevm>
  return 0;
80101636:	b8 00 00 00 00       	mov    $0x0,%eax
8010163b:	eb 2c                	jmp    80101669 <exec+0x419>

 bad:
  if(pgdir)
8010163d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101641:	74 0b                	je     8010164e <exec+0x3fe>
    freevm(pgdir);
80101643:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101646:	89 04 24             	mov    %eax,(%esp)
80101649:	e8 87 75 00 00       	call   80108bd5 <freevm>
  if(ip){
8010164e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101652:	74 10                	je     80101664 <exec+0x414>
    iunlockput(ip);
80101654:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101657:	89 04 24             	mov    %eax,(%esp)
8010165a:	e8 45 0c 00 00       	call   801022a4 <iunlockput>
    end_op();
8010165f:	e8 22 26 00 00       	call   80103c86 <end_op>
  }
  return -1;
80101664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101669:	c9                   	leave  
8010166a:	c3                   	ret    

8010166b <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010166b:	55                   	push   %ebp
8010166c:	89 e5                	mov    %esp,%ebp
8010166e:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80101671:	c7 44 24 04 46 8f 10 	movl   $0x80108f46,0x4(%esp)
80101678:	80 
80101679:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
80101680:	e8 34 41 00 00       	call   801057b9 <initlock>
}
80101685:	c9                   	leave  
80101686:	c3                   	ret    

80101687 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101687:	55                   	push   %ebp
80101688:	89 e5                	mov    %esp,%ebp
8010168a:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
8010168d:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
80101694:	e8 41 41 00 00       	call   801057da <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101699:	c7 45 f4 74 20 11 80 	movl   $0x80112074,-0xc(%ebp)
801016a0:	eb 29                	jmp    801016cb <filealloc+0x44>
    if(f->ref == 0){
801016a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a5:	8b 40 04             	mov    0x4(%eax),%eax
801016a8:	85 c0                	test   %eax,%eax
801016aa:	75 1b                	jne    801016c7 <filealloc+0x40>
      f->ref = 1;
801016ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016af:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801016b6:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
801016bd:	e8 7a 41 00 00       	call   8010583c <release>
      return f;
801016c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c5:	eb 1e                	jmp    801016e5 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801016c7:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801016cb:	81 7d f4 d4 29 11 80 	cmpl   $0x801129d4,-0xc(%ebp)
801016d2:	72 ce                	jb     801016a2 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801016d4:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
801016db:	e8 5c 41 00 00       	call   8010583c <release>
  return 0;
801016e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801016e5:	c9                   	leave  
801016e6:	c3                   	ret    

801016e7 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801016e7:	55                   	push   %ebp
801016e8:	89 e5                	mov    %esp,%ebp
801016ea:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801016ed:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
801016f4:	e8 e1 40 00 00       	call   801057da <acquire>
  if(f->ref < 1)
801016f9:	8b 45 08             	mov    0x8(%ebp),%eax
801016fc:	8b 40 04             	mov    0x4(%eax),%eax
801016ff:	85 c0                	test   %eax,%eax
80101701:	7f 0c                	jg     8010170f <filedup+0x28>
    panic("filedup");
80101703:	c7 04 24 4d 8f 10 80 	movl   $0x80108f4d,(%esp)
8010170a:	e8 2b ee ff ff       	call   8010053a <panic>
  f->ref++;
8010170f:	8b 45 08             	mov    0x8(%ebp),%eax
80101712:	8b 40 04             	mov    0x4(%eax),%eax
80101715:	8d 50 01             	lea    0x1(%eax),%edx
80101718:	8b 45 08             	mov    0x8(%ebp),%eax
8010171b:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010171e:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
80101725:	e8 12 41 00 00       	call   8010583c <release>
  return f;
8010172a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010172d:	c9                   	leave  
8010172e:	c3                   	ret    

8010172f <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010172f:	55                   	push   %ebp
80101730:	89 e5                	mov    %esp,%ebp
80101732:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80101735:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
8010173c:	e8 99 40 00 00       	call   801057da <acquire>
  if(f->ref < 1)
80101741:	8b 45 08             	mov    0x8(%ebp),%eax
80101744:	8b 40 04             	mov    0x4(%eax),%eax
80101747:	85 c0                	test   %eax,%eax
80101749:	7f 0c                	jg     80101757 <fileclose+0x28>
    panic("fileclose");
8010174b:	c7 04 24 55 8f 10 80 	movl   $0x80108f55,(%esp)
80101752:	e8 e3 ed ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80101757:	8b 45 08             	mov    0x8(%ebp),%eax
8010175a:	8b 40 04             	mov    0x4(%eax),%eax
8010175d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101760:	8b 45 08             	mov    0x8(%ebp),%eax
80101763:	89 50 04             	mov    %edx,0x4(%eax)
80101766:	8b 45 08             	mov    0x8(%ebp),%eax
80101769:	8b 40 04             	mov    0x4(%eax),%eax
8010176c:	85 c0                	test   %eax,%eax
8010176e:	7e 11                	jle    80101781 <fileclose+0x52>
    release(&ftable.lock);
80101770:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
80101777:	e8 c0 40 00 00       	call   8010583c <release>
8010177c:	e9 82 00 00 00       	jmp    80101803 <fileclose+0xd4>
    return;
  }
  ff = *f;
80101781:	8b 45 08             	mov    0x8(%ebp),%eax
80101784:	8b 10                	mov    (%eax),%edx
80101786:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101789:	8b 50 04             	mov    0x4(%eax),%edx
8010178c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010178f:	8b 50 08             	mov    0x8(%eax),%edx
80101792:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101795:	8b 50 0c             	mov    0xc(%eax),%edx
80101798:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010179b:	8b 50 10             	mov    0x10(%eax),%edx
8010179e:	89 55 f0             	mov    %edx,-0x10(%ebp)
801017a1:	8b 40 14             	mov    0x14(%eax),%eax
801017a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801017a7:	8b 45 08             	mov    0x8(%ebp),%eax
801017aa:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801017b1:	8b 45 08             	mov    0x8(%ebp),%eax
801017b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801017ba:	c7 04 24 40 20 11 80 	movl   $0x80112040,(%esp)
801017c1:	e8 76 40 00 00       	call   8010583c <release>
  
  if(ff.type == FD_PIPE)
801017c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801017c9:	83 f8 01             	cmp    $0x1,%eax
801017cc:	75 18                	jne    801017e6 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801017ce:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801017d2:	0f be d0             	movsbl %al,%edx
801017d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017d8:	89 54 24 04          	mov    %edx,0x4(%esp)
801017dc:	89 04 24             	mov    %eax,(%esp)
801017df:	e8 6d 30 00 00       	call   80104851 <pipeclose>
801017e4:	eb 1d                	jmp    80101803 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801017e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801017e9:	83 f8 02             	cmp    $0x2,%eax
801017ec:	75 15                	jne    80101803 <fileclose+0xd4>
    begin_op();
801017ee:	e8 0f 24 00 00       	call   80103c02 <begin_op>
    iput(ff.ip);
801017f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f6:	89 04 24             	mov    %eax,(%esp)
801017f9:	e8 d5 09 00 00       	call   801021d3 <iput>
    end_op();
801017fe:	e8 83 24 00 00       	call   80103c86 <end_op>
  }
}
80101803:	c9                   	leave  
80101804:	c3                   	ret    

80101805 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101805:	55                   	push   %ebp
80101806:	89 e5                	mov    %esp,%ebp
80101808:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
8010180b:	8b 45 08             	mov    0x8(%ebp),%eax
8010180e:	8b 00                	mov    (%eax),%eax
80101810:	83 f8 02             	cmp    $0x2,%eax
80101813:	75 38                	jne    8010184d <filestat+0x48>
    ilock(f->ip);
80101815:	8b 45 08             	mov    0x8(%ebp),%eax
80101818:	8b 40 10             	mov    0x10(%eax),%eax
8010181b:	89 04 24             	mov    %eax,(%esp)
8010181e:	e8 f7 07 00 00       	call   8010201a <ilock>
    stati(f->ip, st);
80101823:	8b 45 08             	mov    0x8(%ebp),%eax
80101826:	8b 40 10             	mov    0x10(%eax),%eax
80101829:	8b 55 0c             	mov    0xc(%ebp),%edx
8010182c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101830:	89 04 24             	mov    %eax,(%esp)
80101833:	e8 b0 0c 00 00       	call   801024e8 <stati>
    iunlock(f->ip);
80101838:	8b 45 08             	mov    0x8(%ebp),%eax
8010183b:	8b 40 10             	mov    0x10(%eax),%eax
8010183e:	89 04 24             	mov    %eax,(%esp)
80101841:	e8 28 09 00 00       	call   8010216e <iunlock>
    return 0;
80101846:	b8 00 00 00 00       	mov    $0x0,%eax
8010184b:	eb 05                	jmp    80101852 <filestat+0x4d>
  }
  return -1;
8010184d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101852:	c9                   	leave  
80101853:	c3                   	ret    

80101854 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101854:	55                   	push   %ebp
80101855:	89 e5                	mov    %esp,%ebp
80101857:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
8010185a:	8b 45 08             	mov    0x8(%ebp),%eax
8010185d:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101861:	84 c0                	test   %al,%al
80101863:	75 0a                	jne    8010186f <fileread+0x1b>
    return -1;
80101865:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010186a:	e9 9f 00 00 00       	jmp    8010190e <fileread+0xba>
  if(f->type == FD_PIPE)
8010186f:	8b 45 08             	mov    0x8(%ebp),%eax
80101872:	8b 00                	mov    (%eax),%eax
80101874:	83 f8 01             	cmp    $0x1,%eax
80101877:	75 1e                	jne    80101897 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101879:	8b 45 08             	mov    0x8(%ebp),%eax
8010187c:	8b 40 0c             	mov    0xc(%eax),%eax
8010187f:	8b 55 10             	mov    0x10(%ebp),%edx
80101882:	89 54 24 08          	mov    %edx,0x8(%esp)
80101886:	8b 55 0c             	mov    0xc(%ebp),%edx
80101889:	89 54 24 04          	mov    %edx,0x4(%esp)
8010188d:	89 04 24             	mov    %eax,(%esp)
80101890:	e8 3d 31 00 00       	call   801049d2 <piperead>
80101895:	eb 77                	jmp    8010190e <fileread+0xba>
  if(f->type == FD_INODE){
80101897:	8b 45 08             	mov    0x8(%ebp),%eax
8010189a:	8b 00                	mov    (%eax),%eax
8010189c:	83 f8 02             	cmp    $0x2,%eax
8010189f:	75 61                	jne    80101902 <fileread+0xae>
    ilock(f->ip);
801018a1:	8b 45 08             	mov    0x8(%ebp),%eax
801018a4:	8b 40 10             	mov    0x10(%eax),%eax
801018a7:	89 04 24             	mov    %eax,(%esp)
801018aa:	e8 6b 07 00 00       	call   8010201a <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801018af:	8b 4d 10             	mov    0x10(%ebp),%ecx
801018b2:	8b 45 08             	mov    0x8(%ebp),%eax
801018b5:	8b 50 14             	mov    0x14(%eax),%edx
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8b 40 10             	mov    0x10(%eax),%eax
801018be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801018c2:	89 54 24 08          	mov    %edx,0x8(%esp)
801018c6:	8b 55 0c             	mov    0xc(%ebp),%edx
801018c9:	89 54 24 04          	mov    %edx,0x4(%esp)
801018cd:	89 04 24             	mov    %eax,(%esp)
801018d0:	e8 58 0c 00 00       	call   8010252d <readi>
801018d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801018d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801018dc:	7e 11                	jle    801018ef <fileread+0x9b>
      f->off += r;
801018de:	8b 45 08             	mov    0x8(%ebp),%eax
801018e1:	8b 50 14             	mov    0x14(%eax),%edx
801018e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e7:	01 c2                	add    %eax,%edx
801018e9:	8b 45 08             	mov    0x8(%ebp),%eax
801018ec:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801018ef:	8b 45 08             	mov    0x8(%ebp),%eax
801018f2:	8b 40 10             	mov    0x10(%eax),%eax
801018f5:	89 04 24             	mov    %eax,(%esp)
801018f8:	e8 71 08 00 00       	call   8010216e <iunlock>
    return r;
801018fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101900:	eb 0c                	jmp    8010190e <fileread+0xba>
  }
  panic("fileread");
80101902:	c7 04 24 5f 8f 10 80 	movl   $0x80108f5f,(%esp)
80101909:	e8 2c ec ff ff       	call   8010053a <panic>
}
8010190e:	c9                   	leave  
8010190f:	c3                   	ret    

80101910 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101910:	55                   	push   %ebp
80101911:	89 e5                	mov    %esp,%ebp
80101913:	53                   	push   %ebx
80101914:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101917:	8b 45 08             	mov    0x8(%ebp),%eax
8010191a:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010191e:	84 c0                	test   %al,%al
80101920:	75 0a                	jne    8010192c <filewrite+0x1c>
    return -1;
80101922:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101927:	e9 20 01 00 00       	jmp    80101a4c <filewrite+0x13c>
  if(f->type == FD_PIPE)
8010192c:	8b 45 08             	mov    0x8(%ebp),%eax
8010192f:	8b 00                	mov    (%eax),%eax
80101931:	83 f8 01             	cmp    $0x1,%eax
80101934:	75 21                	jne    80101957 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101936:	8b 45 08             	mov    0x8(%ebp),%eax
80101939:	8b 40 0c             	mov    0xc(%eax),%eax
8010193c:	8b 55 10             	mov    0x10(%ebp),%edx
8010193f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101943:	8b 55 0c             	mov    0xc(%ebp),%edx
80101946:	89 54 24 04          	mov    %edx,0x4(%esp)
8010194a:	89 04 24             	mov    %eax,(%esp)
8010194d:	e8 91 2f 00 00       	call   801048e3 <pipewrite>
80101952:	e9 f5 00 00 00       	jmp    80101a4c <filewrite+0x13c>
  if(f->type == FD_INODE){
80101957:	8b 45 08             	mov    0x8(%ebp),%eax
8010195a:	8b 00                	mov    (%eax),%eax
8010195c:	83 f8 02             	cmp    $0x2,%eax
8010195f:	0f 85 db 00 00 00    	jne    80101a40 <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101965:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010196c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101973:	e9 a8 00 00 00       	jmp    80101a20 <filewrite+0x110>
      int n1 = n - i;
80101978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197b:	8b 55 10             	mov    0x10(%ebp),%edx
8010197e:	29 c2                	sub    %eax,%edx
80101980:	89 d0                	mov    %edx,%eax
80101982:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101988:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010198b:	7e 06                	jle    80101993 <filewrite+0x83>
        n1 = max;
8010198d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101990:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101993:	e8 6a 22 00 00       	call   80103c02 <begin_op>
      ilock(f->ip);
80101998:	8b 45 08             	mov    0x8(%ebp),%eax
8010199b:	8b 40 10             	mov    0x10(%eax),%eax
8010199e:	89 04 24             	mov    %eax,(%esp)
801019a1:	e8 74 06 00 00       	call   8010201a <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801019a6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801019a9:	8b 45 08             	mov    0x8(%ebp),%eax
801019ac:	8b 50 14             	mov    0x14(%eax),%edx
801019af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801019b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801019b5:	01 c3                	add    %eax,%ebx
801019b7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ba:	8b 40 10             	mov    0x10(%eax),%eax
801019bd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801019c1:	89 54 24 08          	mov    %edx,0x8(%esp)
801019c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801019c9:	89 04 24             	mov    %eax,(%esp)
801019cc:	e8 c0 0c 00 00       	call   80102691 <writei>
801019d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
801019d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801019d8:	7e 11                	jle    801019eb <filewrite+0xdb>
        f->off += r;
801019da:	8b 45 08             	mov    0x8(%ebp),%eax
801019dd:	8b 50 14             	mov    0x14(%eax),%edx
801019e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801019e3:	01 c2                	add    %eax,%edx
801019e5:	8b 45 08             	mov    0x8(%ebp),%eax
801019e8:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801019eb:	8b 45 08             	mov    0x8(%ebp),%eax
801019ee:	8b 40 10             	mov    0x10(%eax),%eax
801019f1:	89 04 24             	mov    %eax,(%esp)
801019f4:	e8 75 07 00 00       	call   8010216e <iunlock>
      end_op();
801019f9:	e8 88 22 00 00       	call   80103c86 <end_op>

      if(r < 0)
801019fe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101a02:	79 02                	jns    80101a06 <filewrite+0xf6>
        break;
80101a04:	eb 26                	jmp    80101a2c <filewrite+0x11c>
      if(r != n1)
80101a06:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101a09:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101a0c:	74 0c                	je     80101a1a <filewrite+0x10a>
        panic("short filewrite");
80101a0e:	c7 04 24 68 8f 10 80 	movl   $0x80108f68,(%esp)
80101a15:	e8 20 eb ff ff       	call   8010053a <panic>
      i += r;
80101a1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101a1d:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a23:	3b 45 10             	cmp    0x10(%ebp),%eax
80101a26:	0f 8c 4c ff ff ff    	jl     80101978 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101a32:	75 05                	jne    80101a39 <filewrite+0x129>
80101a34:	8b 45 10             	mov    0x10(%ebp),%eax
80101a37:	eb 05                	jmp    80101a3e <filewrite+0x12e>
80101a39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101a3e:	eb 0c                	jmp    80101a4c <filewrite+0x13c>
  }
  panic("filewrite");
80101a40:	c7 04 24 78 8f 10 80 	movl   $0x80108f78,(%esp)
80101a47:	e8 ee ea ff ff       	call   8010053a <panic>
}
80101a4c:	83 c4 24             	add    $0x24,%esp
80101a4f:	5b                   	pop    %ebx
80101a50:	5d                   	pop    %ebp
80101a51:	c3                   	ret    

80101a52 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101a52:	55                   	push   %ebp
80101a53:	89 e5                	mov    %esp,%ebp
80101a55:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101a62:	00 
80101a63:	89 04 24             	mov    %eax,(%esp)
80101a66:	e8 3b e7 ff ff       	call   801001a6 <bread>
80101a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a71:	83 c0 18             	add    $0x18,%eax
80101a74:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101a7b:	00 
80101a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101a80:	8b 45 0c             	mov    0xc(%ebp),%eax
80101a83:	89 04 24             	mov    %eax,(%esp)
80101a86:	e8 72 40 00 00       	call   80105afd <memmove>
  brelse(bp);
80101a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8e:	89 04 24             	mov    %eax,(%esp)
80101a91:	e8 81 e7 ff ff       	call   80100217 <brelse>
}
80101a96:	c9                   	leave  
80101a97:	c3                   	ret    

80101a98 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101a98:	55                   	push   %ebp
80101a99:	89 e5                	mov    %esp,%ebp
80101a9b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101aa8:	89 04 24             	mov    %eax,(%esp)
80101aab:	e8 f6 e6 ff ff       	call   801001a6 <bread>
80101ab0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab6:	83 c0 18             	add    $0x18,%eax
80101ab9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101ac0:	00 
80101ac1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101ac8:	00 
80101ac9:	89 04 24             	mov    %eax,(%esp)
80101acc:	e8 5d 3f 00 00       	call   80105a2e <memset>
  log_write(bp);
80101ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad4:	89 04 24             	mov    %eax,(%esp)
80101ad7:	e8 31 23 00 00       	call   80103e0d <log_write>
  brelse(bp);
80101adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101adf:	89 04 24             	mov    %eax,(%esp)
80101ae2:	e8 30 e7 ff ff       	call   80100217 <brelse>
}
80101ae7:	c9                   	leave  
80101ae8:	c3                   	ret    

80101ae9 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101ae9:	55                   	push   %ebp
80101aea:	89 e5                	mov    %esp,%ebp
80101aec:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101aef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101af6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101afd:	e9 07 01 00 00       	jmp    80101c09 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
80101b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b05:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101b0b:	85 c0                	test   %eax,%eax
80101b0d:	0f 48 c2             	cmovs  %edx,%eax
80101b10:	c1 f8 0c             	sar    $0xc,%eax
80101b13:	89 c2                	mov    %eax,%edx
80101b15:	a1 58 2a 11 80       	mov    0x80112a58,%eax
80101b1a:	01 d0                	add    %edx,%eax
80101b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101b20:	8b 45 08             	mov    0x8(%ebp),%eax
80101b23:	89 04 24             	mov    %eax,(%esp)
80101b26:	e8 7b e6 ff ff       	call   801001a6 <bread>
80101b2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101b2e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101b35:	e9 9d 00 00 00       	jmp    80101bd7 <balloc+0xee>
      m = 1 << (bi % 8);
80101b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b3d:	99                   	cltd   
80101b3e:	c1 ea 1d             	shr    $0x1d,%edx
80101b41:	01 d0                	add    %edx,%eax
80101b43:	83 e0 07             	and    $0x7,%eax
80101b46:	29 d0                	sub    %edx,%eax
80101b48:	ba 01 00 00 00       	mov    $0x1,%edx
80101b4d:	89 c1                	mov    %eax,%ecx
80101b4f:	d3 e2                	shl    %cl,%edx
80101b51:	89 d0                	mov    %edx,%eax
80101b53:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b59:	8d 50 07             	lea    0x7(%eax),%edx
80101b5c:	85 c0                	test   %eax,%eax
80101b5e:	0f 48 c2             	cmovs  %edx,%eax
80101b61:	c1 f8 03             	sar    $0x3,%eax
80101b64:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101b67:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101b6c:	0f b6 c0             	movzbl %al,%eax
80101b6f:	23 45 e8             	and    -0x18(%ebp),%eax
80101b72:	85 c0                	test   %eax,%eax
80101b74:	75 5d                	jne    80101bd3 <balloc+0xea>
        bp->data[bi/8] |= m;  // Mark block in use.
80101b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b79:	8d 50 07             	lea    0x7(%eax),%edx
80101b7c:	85 c0                	test   %eax,%eax
80101b7e:	0f 48 c2             	cmovs  %edx,%eax
80101b81:	c1 f8 03             	sar    $0x3,%eax
80101b84:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101b87:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101b8c:	89 d1                	mov    %edx,%ecx
80101b8e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101b91:	09 ca                	or     %ecx,%edx
80101b93:	89 d1                	mov    %edx,%ecx
80101b95:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101b98:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101b9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b9f:	89 04 24             	mov    %eax,(%esp)
80101ba2:	e8 66 22 00 00       	call   80103e0d <log_write>
        brelse(bp);
80101ba7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101baa:	89 04 24             	mov    %eax,(%esp)
80101bad:	e8 65 e6 ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bb8:	01 c2                	add    %eax,%edx
80101bba:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbd:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bc1:	89 04 24             	mov    %eax,(%esp)
80101bc4:	e8 cf fe ff ff       	call   80101a98 <bzero>
        return b + bi;
80101bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bcc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bcf:	01 d0                	add    %edx,%eax
80101bd1:	eb 52                	jmp    80101c25 <balloc+0x13c>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101bd3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101bd7:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101bde:	7f 17                	jg     80101bf7 <balloc+0x10e>
80101be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101be6:	01 d0                	add    %edx,%eax
80101be8:	89 c2                	mov    %eax,%edx
80101bea:	a1 40 2a 11 80       	mov    0x80112a40,%eax
80101bef:	39 c2                	cmp    %eax,%edx
80101bf1:	0f 82 43 ff ff ff    	jb     80101b3a <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101bf7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bfa:	89 04 24             	mov    %eax,(%esp)
80101bfd:	e8 15 e6 ff ff       	call   80100217 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101c02:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101c09:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c0c:	a1 40 2a 11 80       	mov    0x80112a40,%eax
80101c11:	39 c2                	cmp    %eax,%edx
80101c13:	0f 82 e9 fe ff ff    	jb     80101b02 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101c19:	c7 04 24 84 8f 10 80 	movl   $0x80108f84,(%esp)
80101c20:	e8 15 e9 ff ff       	call   8010053a <panic>
}
80101c25:	c9                   	leave  
80101c26:	c3                   	ret    

80101c27 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101c27:	55                   	push   %ebp
80101c28:	89 e5                	mov    %esp,%ebp
80101c2a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101c2d:	c7 44 24 04 40 2a 11 	movl   $0x80112a40,0x4(%esp)
80101c34:	80 
80101c35:	8b 45 08             	mov    0x8(%ebp),%eax
80101c38:	89 04 24             	mov    %eax,(%esp)
80101c3b:	e8 12 fe ff ff       	call   80101a52 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101c40:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c43:	c1 e8 0c             	shr    $0xc,%eax
80101c46:	89 c2                	mov    %eax,%edx
80101c48:	a1 58 2a 11 80       	mov    0x80112a58,%eax
80101c4d:	01 c2                	add    %eax,%edx
80101c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c52:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c56:	89 04 24             	mov    %eax,(%esp)
80101c59:	e8 48 e5 ff ff       	call   801001a6 <bread>
80101c5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101c61:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c64:	25 ff 0f 00 00       	and    $0xfff,%eax
80101c69:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c6f:	99                   	cltd   
80101c70:	c1 ea 1d             	shr    $0x1d,%edx
80101c73:	01 d0                	add    %edx,%eax
80101c75:	83 e0 07             	and    $0x7,%eax
80101c78:	29 d0                	sub    %edx,%eax
80101c7a:	ba 01 00 00 00       	mov    $0x1,%edx
80101c7f:	89 c1                	mov    %eax,%ecx
80101c81:	d3 e2                	shl    %cl,%edx
80101c83:	89 d0                	mov    %edx,%eax
80101c85:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c8b:	8d 50 07             	lea    0x7(%eax),%edx
80101c8e:	85 c0                	test   %eax,%eax
80101c90:	0f 48 c2             	cmovs  %edx,%eax
80101c93:	c1 f8 03             	sar    $0x3,%eax
80101c96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c99:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101c9e:	0f b6 c0             	movzbl %al,%eax
80101ca1:	23 45 ec             	and    -0x14(%ebp),%eax
80101ca4:	85 c0                	test   %eax,%eax
80101ca6:	75 0c                	jne    80101cb4 <bfree+0x8d>
    panic("freeing free block");
80101ca8:	c7 04 24 9a 8f 10 80 	movl   $0x80108f9a,(%esp)
80101caf:	e8 86 e8 ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb7:	8d 50 07             	lea    0x7(%eax),%edx
80101cba:	85 c0                	test   %eax,%eax
80101cbc:	0f 48 c2             	cmovs  %edx,%eax
80101cbf:	c1 f8 03             	sar    $0x3,%eax
80101cc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc5:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101cca:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101ccd:	f7 d1                	not    %ecx
80101ccf:	21 ca                	and    %ecx,%edx
80101cd1:	89 d1                	mov    %edx,%ecx
80101cd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd6:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cdd:	89 04 24             	mov    %eax,(%esp)
80101ce0:	e8 28 21 00 00       	call   80103e0d <log_write>
  brelse(bp);
80101ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ce8:	89 04 24             	mov    %eax,(%esp)
80101ceb:	e8 27 e5 ff ff       	call   80100217 <brelse>
}
80101cf0:	c9                   	leave  
80101cf1:	c3                   	ret    

80101cf2 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101cf2:	55                   	push   %ebp
80101cf3:	89 e5                	mov    %esp,%ebp
80101cf5:	57                   	push   %edi
80101cf6:	56                   	push   %esi
80101cf7:	53                   	push   %ebx
80101cf8:	83 ec 3c             	sub    $0x3c,%esp
  initlock(&icache.lock, "icache");
80101cfb:	c7 44 24 04 ad 8f 10 	movl   $0x80108fad,0x4(%esp)
80101d02:	80 
80101d03:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80101d0a:	e8 aa 3a 00 00       	call   801057b9 <initlock>
  readsb(dev, &sb);
80101d0f:	c7 44 24 04 40 2a 11 	movl   $0x80112a40,0x4(%esp)
80101d16:	80 
80101d17:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1a:	89 04 24             	mov    %eax,(%esp)
80101d1d:	e8 30 fd ff ff       	call   80101a52 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101d22:	a1 58 2a 11 80       	mov    0x80112a58,%eax
80101d27:	8b 3d 54 2a 11 80    	mov    0x80112a54,%edi
80101d2d:	8b 35 50 2a 11 80    	mov    0x80112a50,%esi
80101d33:	8b 1d 4c 2a 11 80    	mov    0x80112a4c,%ebx
80101d39:	8b 0d 48 2a 11 80    	mov    0x80112a48,%ecx
80101d3f:	8b 15 44 2a 11 80    	mov    0x80112a44,%edx
80101d45:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101d48:	8b 15 40 2a 11 80    	mov    0x80112a40,%edx
80101d4e:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101d52:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101d56:	89 74 24 14          	mov    %esi,0x14(%esp)
80101d5a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101d5e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101d62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101d65:	89 44 24 08          	mov    %eax,0x8(%esp)
80101d69:	89 d0                	mov    %edx,%eax
80101d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
80101d6f:	c7 04 24 b4 8f 10 80 	movl   $0x80108fb4,(%esp)
80101d76:	e8 25 e6 ff ff       	call   801003a0 <cprintf>
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101d7b:	83 c4 3c             	add    $0x3c,%esp
80101d7e:	5b                   	pop    %ebx
80101d7f:	5e                   	pop    %esi
80101d80:	5f                   	pop    %edi
80101d81:	5d                   	pop    %ebp
80101d82:	c3                   	ret    

80101d83 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101d83:	55                   	push   %ebp
80101d84:	89 e5                	mov    %esp,%ebp
80101d86:	83 ec 28             	sub    $0x28,%esp
80101d89:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d8c:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101d90:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101d97:	e9 9e 00 00 00       	jmp    80101e3a <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d9f:	c1 e8 03             	shr    $0x3,%eax
80101da2:	89 c2                	mov    %eax,%edx
80101da4:	a1 54 2a 11 80       	mov    0x80112a54,%eax
80101da9:	01 d0                	add    %edx,%eax
80101dab:	89 44 24 04          	mov    %eax,0x4(%esp)
80101daf:	8b 45 08             	mov    0x8(%ebp),%eax
80101db2:	89 04 24             	mov    %eax,(%esp)
80101db5:	e8 ec e3 ff ff       	call   801001a6 <bread>
80101dba:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dc0:	8d 50 18             	lea    0x18(%eax),%edx
80101dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dc6:	83 e0 07             	and    $0x7,%eax
80101dc9:	c1 e0 06             	shl    $0x6,%eax
80101dcc:	01 d0                	add    %edx,%eax
80101dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101dd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dd4:	0f b7 00             	movzwl (%eax),%eax
80101dd7:	66 85 c0             	test   %ax,%ax
80101dda:	75 4f                	jne    80101e2b <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
80101ddc:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101de3:	00 
80101de4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101deb:	00 
80101dec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101def:	89 04 24             	mov    %eax,(%esp)
80101df2:	e8 37 3c 00 00       	call   80105a2e <memset>
      dip->type = type;
80101df7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dfa:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101dfe:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e04:	89 04 24             	mov    %eax,(%esp)
80101e07:	e8 01 20 00 00       	call   80103e0d <log_write>
      brelse(bp);
80101e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e0f:	89 04 24             	mov    %eax,(%esp)
80101e12:	e8 00 e4 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e21:	89 04 24             	mov    %eax,(%esp)
80101e24:	e8 ed 00 00 00       	call   80101f16 <iget>
80101e29:	eb 2b                	jmp    80101e56 <ialloc+0xd3>
    }
    brelse(bp);
80101e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2e:	89 04 24             	mov    %eax,(%esp)
80101e31:	e8 e1 e3 ff ff       	call   80100217 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101e36:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e3d:	a1 48 2a 11 80       	mov    0x80112a48,%eax
80101e42:	39 c2                	cmp    %eax,%edx
80101e44:	0f 82 52 ff ff ff    	jb     80101d9c <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101e4a:	c7 04 24 07 90 10 80 	movl   $0x80109007,(%esp)
80101e51:	e8 e4 e6 ff ff       	call   8010053a <panic>
}
80101e56:	c9                   	leave  
80101e57:	c3                   	ret    

80101e58 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101e58:	55                   	push   %ebp
80101e59:	89 e5                	mov    %esp,%ebp
80101e5b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e61:	8b 40 04             	mov    0x4(%eax),%eax
80101e64:	c1 e8 03             	shr    $0x3,%eax
80101e67:	89 c2                	mov    %eax,%edx
80101e69:	a1 54 2a 11 80       	mov    0x80112a54,%eax
80101e6e:	01 c2                	add    %eax,%edx
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	8b 00                	mov    (%eax),%eax
80101e75:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e79:	89 04 24             	mov    %eax,(%esp)
80101e7c:	e8 25 e3 ff ff       	call   801001a6 <bread>
80101e81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e87:	8d 50 18             	lea    0x18(%eax),%edx
80101e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8d:	8b 40 04             	mov    0x4(%eax),%eax
80101e90:	83 e0 07             	and    $0x7,%eax
80101e93:	c1 e0 06             	shl    $0x6,%eax
80101e96:	01 d0                	add    %edx,%eax
80101e98:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101ea2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eab:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eb2:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101eb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb9:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ec0:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec7:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ece:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed5:	8b 50 18             	mov    0x18(%eax),%edx
80101ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101edb:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101ede:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee1:	8d 50 1c             	lea    0x1c(%eax),%edx
80101ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee7:	83 c0 0c             	add    $0xc,%eax
80101eea:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101ef1:	00 
80101ef2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ef6:	89 04 24             	mov    %eax,(%esp)
80101ef9:	e8 ff 3b 00 00       	call   80105afd <memmove>
  log_write(bp);
80101efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f01:	89 04 24             	mov    %eax,(%esp)
80101f04:	e8 04 1f 00 00       	call   80103e0d <log_write>
  brelse(bp);
80101f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f0c:	89 04 24             	mov    %eax,(%esp)
80101f0f:	e8 03 e3 ff ff       	call   80100217 <brelse>
}
80101f14:	c9                   	leave  
80101f15:	c3                   	ret    

80101f16 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101f16:	55                   	push   %ebp
80101f17:	89 e5                	mov    %esp,%ebp
80101f19:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101f1c:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80101f23:	e8 b2 38 00 00       	call   801057da <acquire>

  // Is the inode already cached?
  empty = 0;
80101f28:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101f2f:	c7 45 f4 94 2a 11 80 	movl   $0x80112a94,-0xc(%ebp)
80101f36:	eb 59                	jmp    80101f91 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f3b:	8b 40 08             	mov    0x8(%eax),%eax
80101f3e:	85 c0                	test   %eax,%eax
80101f40:	7e 35                	jle    80101f77 <iget+0x61>
80101f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f45:	8b 00                	mov    (%eax),%eax
80101f47:	3b 45 08             	cmp    0x8(%ebp),%eax
80101f4a:	75 2b                	jne    80101f77 <iget+0x61>
80101f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f4f:	8b 40 04             	mov    0x4(%eax),%eax
80101f52:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101f55:	75 20                	jne    80101f77 <iget+0x61>
      ip->ref++;
80101f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f5a:	8b 40 08             	mov    0x8(%eax),%eax
80101f5d:	8d 50 01             	lea    0x1(%eax),%edx
80101f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f63:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101f66:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80101f6d:	e8 ca 38 00 00       	call   8010583c <release>
      return ip;
80101f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f75:	eb 6f                	jmp    80101fe6 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101f77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101f7b:	75 10                	jne    80101f8d <iget+0x77>
80101f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f80:	8b 40 08             	mov    0x8(%eax),%eax
80101f83:	85 c0                	test   %eax,%eax
80101f85:	75 06                	jne    80101f8d <iget+0x77>
      empty = ip;
80101f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f8a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101f8d:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101f91:	81 7d f4 34 3a 11 80 	cmpl   $0x80113a34,-0xc(%ebp)
80101f98:	72 9e                	jb     80101f38 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101f9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101f9e:	75 0c                	jne    80101fac <iget+0x96>
    panic("iget: no inodes");
80101fa0:	c7 04 24 19 90 10 80 	movl   $0x80109019,(%esp)
80101fa7:	e8 8e e5 ff ff       	call   8010053a <panic>

  ip = empty;
80101fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101faf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fb5:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb8:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fbd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fc0:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fc6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fd0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101fd7:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80101fde:	e8 59 38 00 00       	call   8010583c <release>

  return ip;
80101fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101fe6:	c9                   	leave  
80101fe7:	c3                   	ret    

80101fe8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101fe8:	55                   	push   %ebp
80101fe9:	89 e5                	mov    %esp,%ebp
80101feb:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101fee:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80101ff5:	e8 e0 37 00 00       	call   801057da <acquire>
  ip->ref++;
80101ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffd:	8b 40 08             	mov    0x8(%eax),%eax
80102000:	8d 50 01             	lea    0x1(%eax),%edx
80102003:	8b 45 08             	mov    0x8(%ebp),%eax
80102006:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80102009:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80102010:	e8 27 38 00 00       	call   8010583c <release>
  return ip;
80102015:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102018:	c9                   	leave  
80102019:	c3                   	ret    

8010201a <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010201a:	55                   	push   %ebp
8010201b:	89 e5                	mov    %esp,%ebp
8010201d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80102020:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102024:	74 0a                	je     80102030 <ilock+0x16>
80102026:	8b 45 08             	mov    0x8(%ebp),%eax
80102029:	8b 40 08             	mov    0x8(%eax),%eax
8010202c:	85 c0                	test   %eax,%eax
8010202e:	7f 0c                	jg     8010203c <ilock+0x22>
    panic("ilock");
80102030:	c7 04 24 29 90 10 80 	movl   $0x80109029,(%esp)
80102037:	e8 fe e4 ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010203c:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80102043:	e8 92 37 00 00       	call   801057da <acquire>
  while(ip->flags & I_BUSY)
80102048:	eb 13                	jmp    8010205d <ilock+0x43>
    sleep(ip, &icache.lock);
8010204a:	c7 44 24 04 60 2a 11 	movl   $0x80112a60,0x4(%esp)
80102051:	80 
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	89 04 24             	mov    %eax,(%esp)
80102058:	e8 2e 34 00 00       	call   8010548b <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
8010205d:	8b 45 08             	mov    0x8(%ebp),%eax
80102060:	8b 40 0c             	mov    0xc(%eax),%eax
80102063:	83 e0 01             	and    $0x1,%eax
80102066:	85 c0                	test   %eax,%eax
80102068:	75 e0                	jne    8010204a <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
8010206a:	8b 45 08             	mov    0x8(%ebp),%eax
8010206d:	8b 40 0c             	mov    0xc(%eax),%eax
80102070:	83 c8 01             	or     $0x1,%eax
80102073:	89 c2                	mov    %eax,%edx
80102075:	8b 45 08             	mov    0x8(%ebp),%eax
80102078:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
8010207b:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80102082:	e8 b5 37 00 00       	call   8010583c <release>

  if(!(ip->flags & I_VALID)){
80102087:	8b 45 08             	mov    0x8(%ebp),%eax
8010208a:	8b 40 0c             	mov    0xc(%eax),%eax
8010208d:	83 e0 02             	and    $0x2,%eax
80102090:	85 c0                	test   %eax,%eax
80102092:	0f 85 d4 00 00 00    	jne    8010216c <ilock+0x152>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80102098:	8b 45 08             	mov    0x8(%ebp),%eax
8010209b:	8b 40 04             	mov    0x4(%eax),%eax
8010209e:	c1 e8 03             	shr    $0x3,%eax
801020a1:	89 c2                	mov    %eax,%edx
801020a3:	a1 54 2a 11 80       	mov    0x80112a54,%eax
801020a8:	01 c2                	add    %eax,%edx
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	8b 00                	mov    (%eax),%eax
801020af:	89 54 24 04          	mov    %edx,0x4(%esp)
801020b3:	89 04 24             	mov    %eax,(%esp)
801020b6:	e8 eb e0 ff ff       	call   801001a6 <bread>
801020bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801020be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020c1:	8d 50 18             	lea    0x18(%eax),%edx
801020c4:	8b 45 08             	mov    0x8(%ebp),%eax
801020c7:	8b 40 04             	mov    0x4(%eax),%eax
801020ca:	83 e0 07             	and    $0x7,%eax
801020cd:	c1 e0 06             	shl    $0x6,%eax
801020d0:	01 d0                	add    %edx,%eax
801020d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801020d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020d8:	0f b7 10             	movzwl (%eax),%edx
801020db:	8b 45 08             	mov    0x8(%ebp),%eax
801020de:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801020e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020e5:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801020e9:	8b 45 08             	mov    0x8(%ebp),%eax
801020ec:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801020f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020f3:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801020f7:	8b 45 08             	mov    0x8(%ebp),%eax
801020fa:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801020fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102101:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80102105:	8b 45 08             	mov    0x8(%ebp),%eax
80102108:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
8010210c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010210f:	8b 50 08             	mov    0x8(%eax),%edx
80102112:	8b 45 08             	mov    0x8(%ebp),%eax
80102115:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80102118:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010211b:	8d 50 0c             	lea    0xc(%eax),%edx
8010211e:	8b 45 08             	mov    0x8(%ebp),%eax
80102121:	83 c0 1c             	add    $0x1c,%eax
80102124:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010212b:	00 
8010212c:	89 54 24 04          	mov    %edx,0x4(%esp)
80102130:	89 04 24             	mov    %eax,(%esp)
80102133:	e8 c5 39 00 00       	call   80105afd <memmove>
    brelse(bp);
80102138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010213b:	89 04 24             	mov    %eax,(%esp)
8010213e:	e8 d4 e0 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80102143:	8b 45 08             	mov    0x8(%ebp),%eax
80102146:	8b 40 0c             	mov    0xc(%eax),%eax
80102149:	83 c8 02             	or     $0x2,%eax
8010214c:	89 c2                	mov    %eax,%edx
8010214e:	8b 45 08             	mov    0x8(%ebp),%eax
80102151:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80102154:	8b 45 08             	mov    0x8(%ebp),%eax
80102157:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010215b:	66 85 c0             	test   %ax,%ax
8010215e:	75 0c                	jne    8010216c <ilock+0x152>
      panic("ilock: no type");
80102160:	c7 04 24 2f 90 10 80 	movl   $0x8010902f,(%esp)
80102167:	e8 ce e3 ff ff       	call   8010053a <panic>
  }
}
8010216c:	c9                   	leave  
8010216d:	c3                   	ret    

8010216e <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
8010216e:	55                   	push   %ebp
8010216f:	89 e5                	mov    %esp,%ebp
80102171:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80102174:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102178:	74 17                	je     80102191 <iunlock+0x23>
8010217a:	8b 45 08             	mov    0x8(%ebp),%eax
8010217d:	8b 40 0c             	mov    0xc(%eax),%eax
80102180:	83 e0 01             	and    $0x1,%eax
80102183:	85 c0                	test   %eax,%eax
80102185:	74 0a                	je     80102191 <iunlock+0x23>
80102187:	8b 45 08             	mov    0x8(%ebp),%eax
8010218a:	8b 40 08             	mov    0x8(%eax),%eax
8010218d:	85 c0                	test   %eax,%eax
8010218f:	7f 0c                	jg     8010219d <iunlock+0x2f>
    panic("iunlock");
80102191:	c7 04 24 3e 90 10 80 	movl   $0x8010903e,(%esp)
80102198:	e8 9d e3 ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
8010219d:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
801021a4:	e8 31 36 00 00       	call   801057da <acquire>
  ip->flags &= ~I_BUSY;
801021a9:	8b 45 08             	mov    0x8(%ebp),%eax
801021ac:	8b 40 0c             	mov    0xc(%eax),%eax
801021af:	83 e0 fe             	and    $0xfffffffe,%eax
801021b2:	89 c2                	mov    %eax,%edx
801021b4:	8b 45 08             	mov    0x8(%ebp),%eax
801021b7:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
801021ba:	8b 45 08             	mov    0x8(%ebp),%eax
801021bd:	89 04 24             	mov    %eax,(%esp)
801021c0:	e8 a2 33 00 00       	call   80105567 <wakeup>
  release(&icache.lock);
801021c5:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
801021cc:	e8 6b 36 00 00       	call   8010583c <release>
}
801021d1:	c9                   	leave  
801021d2:	c3                   	ret    

801021d3 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
801021d3:	55                   	push   %ebp
801021d4:	89 e5                	mov    %esp,%ebp
801021d6:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801021d9:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
801021e0:	e8 f5 35 00 00       	call   801057da <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
801021e5:	8b 45 08             	mov    0x8(%ebp),%eax
801021e8:	8b 40 08             	mov    0x8(%eax),%eax
801021eb:	83 f8 01             	cmp    $0x1,%eax
801021ee:	0f 85 93 00 00 00    	jne    80102287 <iput+0xb4>
801021f4:	8b 45 08             	mov    0x8(%ebp),%eax
801021f7:	8b 40 0c             	mov    0xc(%eax),%eax
801021fa:	83 e0 02             	and    $0x2,%eax
801021fd:	85 c0                	test   %eax,%eax
801021ff:	0f 84 82 00 00 00    	je     80102287 <iput+0xb4>
80102205:	8b 45 08             	mov    0x8(%ebp),%eax
80102208:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010220c:	66 85 c0             	test   %ax,%ax
8010220f:	75 76                	jne    80102287 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80102211:	8b 45 08             	mov    0x8(%ebp),%eax
80102214:	8b 40 0c             	mov    0xc(%eax),%eax
80102217:	83 e0 01             	and    $0x1,%eax
8010221a:	85 c0                	test   %eax,%eax
8010221c:	74 0c                	je     8010222a <iput+0x57>
      panic("iput busy");
8010221e:	c7 04 24 46 90 10 80 	movl   $0x80109046,(%esp)
80102225:	e8 10 e3 ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
8010222a:	8b 45 08             	mov    0x8(%ebp),%eax
8010222d:	8b 40 0c             	mov    0xc(%eax),%eax
80102230:	83 c8 01             	or     $0x1,%eax
80102233:	89 c2                	mov    %eax,%edx
80102235:	8b 45 08             	mov    0x8(%ebp),%eax
80102238:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
8010223b:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
80102242:	e8 f5 35 00 00       	call   8010583c <release>
    itrunc(ip);
80102247:	8b 45 08             	mov    0x8(%ebp),%eax
8010224a:	89 04 24             	mov    %eax,(%esp)
8010224d:	e8 7d 01 00 00       	call   801023cf <itrunc>
    ip->type = 0;
80102252:	8b 45 08             	mov    0x8(%ebp),%eax
80102255:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
8010225b:	8b 45 08             	mov    0x8(%ebp),%eax
8010225e:	89 04 24             	mov    %eax,(%esp)
80102261:	e8 f2 fb ff ff       	call   80101e58 <iupdate>
    acquire(&icache.lock);
80102266:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
8010226d:	e8 68 35 00 00       	call   801057da <acquire>
    ip->flags = 0;
80102272:	8b 45 08             	mov    0x8(%ebp),%eax
80102275:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
8010227c:	8b 45 08             	mov    0x8(%ebp),%eax
8010227f:	89 04 24             	mov    %eax,(%esp)
80102282:	e8 e0 32 00 00       	call   80105567 <wakeup>
  }
  ip->ref--;
80102287:	8b 45 08             	mov    0x8(%ebp),%eax
8010228a:	8b 40 08             	mov    0x8(%eax),%eax
8010228d:	8d 50 ff             	lea    -0x1(%eax),%edx
80102290:	8b 45 08             	mov    0x8(%ebp),%eax
80102293:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80102296:	c7 04 24 60 2a 11 80 	movl   $0x80112a60,(%esp)
8010229d:	e8 9a 35 00 00       	call   8010583c <release>
}
801022a2:	c9                   	leave  
801022a3:	c3                   	ret    

801022a4 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
801022a4:	55                   	push   %ebp
801022a5:	89 e5                	mov    %esp,%ebp
801022a7:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
801022aa:	8b 45 08             	mov    0x8(%ebp),%eax
801022ad:	89 04 24             	mov    %eax,(%esp)
801022b0:	e8 b9 fe ff ff       	call   8010216e <iunlock>
  iput(ip);
801022b5:	8b 45 08             	mov    0x8(%ebp),%eax
801022b8:	89 04 24             	mov    %eax,(%esp)
801022bb:	e8 13 ff ff ff       	call   801021d3 <iput>
}
801022c0:	c9                   	leave  
801022c1:	c3                   	ret    

801022c2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
801022c2:	55                   	push   %ebp
801022c3:	89 e5                	mov    %esp,%ebp
801022c5:	53                   	push   %ebx
801022c6:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
801022c9:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
801022cd:	77 3e                	ja     8010230d <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
801022cf:	8b 45 08             	mov    0x8(%ebp),%eax
801022d2:	8b 55 0c             	mov    0xc(%ebp),%edx
801022d5:	83 c2 04             	add    $0x4,%edx
801022d8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801022dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801022e3:	75 20                	jne    80102305 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
801022e5:	8b 45 08             	mov    0x8(%ebp),%eax
801022e8:	8b 00                	mov    (%eax),%eax
801022ea:	89 04 24             	mov    %eax,(%esp)
801022ed:	e8 f7 f7 ff ff       	call   80101ae9 <balloc>
801022f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022f5:	8b 45 08             	mov    0x8(%ebp),%eax
801022f8:	8b 55 0c             	mov    0xc(%ebp),%edx
801022fb:	8d 4a 04             	lea    0x4(%edx),%ecx
801022fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102301:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80102305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102308:	e9 bc 00 00 00       	jmp    801023c9 <bmap+0x107>
  }
  bn -= NDIRECT;
8010230d:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80102311:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80102315:	0f 87 a2 00 00 00    	ja     801023bd <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
8010231b:	8b 45 08             	mov    0x8(%ebp),%eax
8010231e:	8b 40 4c             	mov    0x4c(%eax),%eax
80102321:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102324:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102328:	75 19                	jne    80102343 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
8010232a:	8b 45 08             	mov    0x8(%ebp),%eax
8010232d:	8b 00                	mov    (%eax),%eax
8010232f:	89 04 24             	mov    %eax,(%esp)
80102332:	e8 b2 f7 ff ff       	call   80101ae9 <balloc>
80102337:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010233a:	8b 45 08             	mov    0x8(%ebp),%eax
8010233d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102340:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80102343:	8b 45 08             	mov    0x8(%ebp),%eax
80102346:	8b 00                	mov    (%eax),%eax
80102348:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010234b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010234f:	89 04 24             	mov    %eax,(%esp)
80102352:	e8 4f de ff ff       	call   801001a6 <bread>
80102357:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
8010235a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010235d:	83 c0 18             	add    $0x18,%eax
80102360:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80102363:	8b 45 0c             	mov    0xc(%ebp),%eax
80102366:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010236d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102370:	01 d0                	add    %edx,%eax
80102372:	8b 00                	mov    (%eax),%eax
80102374:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102377:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010237b:	75 30                	jne    801023ad <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
8010237d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102380:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102387:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010238a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010238d:	8b 45 08             	mov    0x8(%ebp),%eax
80102390:	8b 00                	mov    (%eax),%eax
80102392:	89 04 24             	mov    %eax,(%esp)
80102395:	e8 4f f7 ff ff       	call   80101ae9 <balloc>
8010239a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010239d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a0:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
801023a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023a5:	89 04 24             	mov    %eax,(%esp)
801023a8:	e8 60 1a 00 00       	call   80103e0d <log_write>
    }
    brelse(bp);
801023ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023b0:	89 04 24             	mov    %eax,(%esp)
801023b3:	e8 5f de ff ff       	call   80100217 <brelse>
    return addr;
801023b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bb:	eb 0c                	jmp    801023c9 <bmap+0x107>
  }

  panic("bmap: out of range");
801023bd:	c7 04 24 50 90 10 80 	movl   $0x80109050,(%esp)
801023c4:	e8 71 e1 ff ff       	call   8010053a <panic>
}
801023c9:	83 c4 24             	add    $0x24,%esp
801023cc:	5b                   	pop    %ebx
801023cd:	5d                   	pop    %ebp
801023ce:	c3                   	ret    

801023cf <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
801023cf:	55                   	push   %ebp
801023d0:	89 e5                	mov    %esp,%ebp
801023d2:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801023d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023dc:	eb 44                	jmp    80102422 <itrunc+0x53>
    if(ip->addrs[i]){
801023de:	8b 45 08             	mov    0x8(%ebp),%eax
801023e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023e4:	83 c2 04             	add    $0x4,%edx
801023e7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801023eb:	85 c0                	test   %eax,%eax
801023ed:	74 2f                	je     8010241e <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023f5:	83 c2 04             	add    $0x4,%edx
801023f8:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
801023fc:	8b 45 08             	mov    0x8(%ebp),%eax
801023ff:	8b 00                	mov    (%eax),%eax
80102401:	89 54 24 04          	mov    %edx,0x4(%esp)
80102405:	89 04 24             	mov    %eax,(%esp)
80102408:	e8 1a f8 ff ff       	call   80101c27 <bfree>
      ip->addrs[i] = 0;
8010240d:	8b 45 08             	mov    0x8(%ebp),%eax
80102410:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102413:	83 c2 04             	add    $0x4,%edx
80102416:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010241d:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
8010241e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102422:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102426:	7e b6                	jle    801023de <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80102428:	8b 45 08             	mov    0x8(%ebp),%eax
8010242b:	8b 40 4c             	mov    0x4c(%eax),%eax
8010242e:	85 c0                	test   %eax,%eax
80102430:	0f 84 9b 00 00 00    	je     801024d1 <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80102436:	8b 45 08             	mov    0x8(%ebp),%eax
80102439:	8b 50 4c             	mov    0x4c(%eax),%edx
8010243c:	8b 45 08             	mov    0x8(%ebp),%eax
8010243f:	8b 00                	mov    (%eax),%eax
80102441:	89 54 24 04          	mov    %edx,0x4(%esp)
80102445:	89 04 24             	mov    %eax,(%esp)
80102448:	e8 59 dd ff ff       	call   801001a6 <bread>
8010244d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80102450:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102453:	83 c0 18             	add    $0x18,%eax
80102456:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80102459:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102460:	eb 3b                	jmp    8010249d <itrunc+0xce>
      if(a[j])
80102462:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102465:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010246c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010246f:	01 d0                	add    %edx,%eax
80102471:	8b 00                	mov    (%eax),%eax
80102473:	85 c0                	test   %eax,%eax
80102475:	74 22                	je     80102499 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80102477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010247a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102481:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102484:	01 d0                	add    %edx,%eax
80102486:	8b 10                	mov    (%eax),%edx
80102488:	8b 45 08             	mov    0x8(%ebp),%eax
8010248b:	8b 00                	mov    (%eax),%eax
8010248d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102491:	89 04 24             	mov    %eax,(%esp)
80102494:	e8 8e f7 ff ff       	call   80101c27 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80102499:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010249d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024a0:	83 f8 7f             	cmp    $0x7f,%eax
801024a3:	76 bd                	jbe    80102462 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
801024a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801024a8:	89 04 24             	mov    %eax,(%esp)
801024ab:	e8 67 dd ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801024b0:	8b 45 08             	mov    0x8(%ebp),%eax
801024b3:	8b 50 4c             	mov    0x4c(%eax),%edx
801024b6:	8b 45 08             	mov    0x8(%ebp),%eax
801024b9:	8b 00                	mov    (%eax),%eax
801024bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801024bf:	89 04 24             	mov    %eax,(%esp)
801024c2:	e8 60 f7 ff ff       	call   80101c27 <bfree>
    ip->addrs[NDIRECT] = 0;
801024c7:	8b 45 08             	mov    0x8(%ebp),%eax
801024ca:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
801024d1:	8b 45 08             	mov    0x8(%ebp),%eax
801024d4:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
801024db:	8b 45 08             	mov    0x8(%ebp),%eax
801024de:	89 04 24             	mov    %eax,(%esp)
801024e1:	e8 72 f9 ff ff       	call   80101e58 <iupdate>
}
801024e6:	c9                   	leave  
801024e7:	c3                   	ret    

801024e8 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
801024e8:	55                   	push   %ebp
801024e9:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
801024eb:	8b 45 08             	mov    0x8(%ebp),%eax
801024ee:	8b 00                	mov    (%eax),%eax
801024f0:	89 c2                	mov    %eax,%edx
801024f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801024f5:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
801024f8:	8b 45 08             	mov    0x8(%ebp),%eax
801024fb:	8b 50 04             	mov    0x4(%eax),%edx
801024fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80102501:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102504:	8b 45 08             	mov    0x8(%ebp),%eax
80102507:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010250b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010250e:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102511:	8b 45 08             	mov    0x8(%ebp),%eax
80102514:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102518:	8b 45 0c             	mov    0xc(%ebp),%eax
8010251b:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010251f:	8b 45 08             	mov    0x8(%ebp),%eax
80102522:	8b 50 18             	mov    0x18(%eax),%edx
80102525:	8b 45 0c             	mov    0xc(%ebp),%eax
80102528:	89 50 10             	mov    %edx,0x10(%eax)
}
8010252b:	5d                   	pop    %ebp
8010252c:	c3                   	ret    

8010252d <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010252d:	55                   	push   %ebp
8010252e:	89 e5                	mov    %esp,%ebp
80102530:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102533:	8b 45 08             	mov    0x8(%ebp),%eax
80102536:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010253a:	66 83 f8 03          	cmp    $0x3,%ax
8010253e:	75 60                	jne    801025a0 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102540:	8b 45 08             	mov    0x8(%ebp),%eax
80102543:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102547:	66 85 c0             	test   %ax,%ax
8010254a:	78 20                	js     8010256c <readi+0x3f>
8010254c:	8b 45 08             	mov    0x8(%ebp),%eax
8010254f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102553:	66 83 f8 09          	cmp    $0x9,%ax
80102557:	7f 13                	jg     8010256c <readi+0x3f>
80102559:	8b 45 08             	mov    0x8(%ebp),%eax
8010255c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102560:	98                   	cwtl   
80102561:	8b 04 c5 e0 29 11 80 	mov    -0x7feed620(,%eax,8),%eax
80102568:	85 c0                	test   %eax,%eax
8010256a:	75 0a                	jne    80102576 <readi+0x49>
      return -1;
8010256c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102571:	e9 19 01 00 00       	jmp    8010268f <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80102576:	8b 45 08             	mov    0x8(%ebp),%eax
80102579:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010257d:	98                   	cwtl   
8010257e:	8b 04 c5 e0 29 11 80 	mov    -0x7feed620(,%eax,8),%eax
80102585:	8b 55 14             	mov    0x14(%ebp),%edx
80102588:	89 54 24 08          	mov    %edx,0x8(%esp)
8010258c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010258f:	89 54 24 04          	mov    %edx,0x4(%esp)
80102593:	8b 55 08             	mov    0x8(%ebp),%edx
80102596:	89 14 24             	mov    %edx,(%esp)
80102599:	ff d0                	call   *%eax
8010259b:	e9 ef 00 00 00       	jmp    8010268f <readi+0x162>
  }

  if(off > ip->size || off + n < off)
801025a0:	8b 45 08             	mov    0x8(%ebp),%eax
801025a3:	8b 40 18             	mov    0x18(%eax),%eax
801025a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801025a9:	72 0d                	jb     801025b8 <readi+0x8b>
801025ab:	8b 45 14             	mov    0x14(%ebp),%eax
801025ae:	8b 55 10             	mov    0x10(%ebp),%edx
801025b1:	01 d0                	add    %edx,%eax
801025b3:	3b 45 10             	cmp    0x10(%ebp),%eax
801025b6:	73 0a                	jae    801025c2 <readi+0x95>
    return -1;
801025b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025bd:	e9 cd 00 00 00       	jmp    8010268f <readi+0x162>
  if(off + n > ip->size)
801025c2:	8b 45 14             	mov    0x14(%ebp),%eax
801025c5:	8b 55 10             	mov    0x10(%ebp),%edx
801025c8:	01 c2                	add    %eax,%edx
801025ca:	8b 45 08             	mov    0x8(%ebp),%eax
801025cd:	8b 40 18             	mov    0x18(%eax),%eax
801025d0:	39 c2                	cmp    %eax,%edx
801025d2:	76 0c                	jbe    801025e0 <readi+0xb3>
    n = ip->size - off;
801025d4:	8b 45 08             	mov    0x8(%ebp),%eax
801025d7:	8b 40 18             	mov    0x18(%eax),%eax
801025da:	2b 45 10             	sub    0x10(%ebp),%eax
801025dd:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801025e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e7:	e9 94 00 00 00       	jmp    80102680 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801025ec:	8b 45 10             	mov    0x10(%ebp),%eax
801025ef:	c1 e8 09             	shr    $0x9,%eax
801025f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801025f6:	8b 45 08             	mov    0x8(%ebp),%eax
801025f9:	89 04 24             	mov    %eax,(%esp)
801025fc:	e8 c1 fc ff ff       	call   801022c2 <bmap>
80102601:	8b 55 08             	mov    0x8(%ebp),%edx
80102604:	8b 12                	mov    (%edx),%edx
80102606:	89 44 24 04          	mov    %eax,0x4(%esp)
8010260a:	89 14 24             	mov    %edx,(%esp)
8010260d:	e8 94 db ff ff       	call   801001a6 <bread>
80102612:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102615:	8b 45 10             	mov    0x10(%ebp),%eax
80102618:	25 ff 01 00 00       	and    $0x1ff,%eax
8010261d:	89 c2                	mov    %eax,%edx
8010261f:	b8 00 02 00 00       	mov    $0x200,%eax
80102624:	29 d0                	sub    %edx,%eax
80102626:	89 c2                	mov    %eax,%edx
80102628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262b:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010262e:	29 c1                	sub    %eax,%ecx
80102630:	89 c8                	mov    %ecx,%eax
80102632:	39 c2                	cmp    %eax,%edx
80102634:	0f 46 c2             	cmovbe %edx,%eax
80102637:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010263a:	8b 45 10             	mov    0x10(%ebp),%eax
8010263d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102642:	8d 50 10             	lea    0x10(%eax),%edx
80102645:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102648:	01 d0                	add    %edx,%eax
8010264a:	8d 50 08             	lea    0x8(%eax),%edx
8010264d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102650:	89 44 24 08          	mov    %eax,0x8(%esp)
80102654:	89 54 24 04          	mov    %edx,0x4(%esp)
80102658:	8b 45 0c             	mov    0xc(%ebp),%eax
8010265b:	89 04 24             	mov    %eax,(%esp)
8010265e:	e8 9a 34 00 00       	call   80105afd <memmove>
    brelse(bp);
80102663:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102666:	89 04 24             	mov    %eax,(%esp)
80102669:	e8 a9 db ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010266e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102671:	01 45 f4             	add    %eax,-0xc(%ebp)
80102674:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102677:	01 45 10             	add    %eax,0x10(%ebp)
8010267a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010267d:	01 45 0c             	add    %eax,0xc(%ebp)
80102680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102683:	3b 45 14             	cmp    0x14(%ebp),%eax
80102686:	0f 82 60 ff ff ff    	jb     801025ec <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010268c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010268f:	c9                   	leave  
80102690:	c3                   	ret    

80102691 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102691:	55                   	push   %ebp
80102692:	89 e5                	mov    %esp,%ebp
80102694:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102697:	8b 45 08             	mov    0x8(%ebp),%eax
8010269a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010269e:	66 83 f8 03          	cmp    $0x3,%ax
801026a2:	75 60                	jne    80102704 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801026a4:	8b 45 08             	mov    0x8(%ebp),%eax
801026a7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801026ab:	66 85 c0             	test   %ax,%ax
801026ae:	78 20                	js     801026d0 <writei+0x3f>
801026b0:	8b 45 08             	mov    0x8(%ebp),%eax
801026b3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801026b7:	66 83 f8 09          	cmp    $0x9,%ax
801026bb:	7f 13                	jg     801026d0 <writei+0x3f>
801026bd:	8b 45 08             	mov    0x8(%ebp),%eax
801026c0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801026c4:	98                   	cwtl   
801026c5:	8b 04 c5 e4 29 11 80 	mov    -0x7feed61c(,%eax,8),%eax
801026cc:	85 c0                	test   %eax,%eax
801026ce:	75 0a                	jne    801026da <writei+0x49>
      return -1;
801026d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026d5:	e9 44 01 00 00       	jmp    8010281e <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
801026da:	8b 45 08             	mov    0x8(%ebp),%eax
801026dd:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801026e1:	98                   	cwtl   
801026e2:	8b 04 c5 e4 29 11 80 	mov    -0x7feed61c(,%eax,8),%eax
801026e9:	8b 55 14             	mov    0x14(%ebp),%edx
801026ec:	89 54 24 08          	mov    %edx,0x8(%esp)
801026f0:	8b 55 0c             	mov    0xc(%ebp),%edx
801026f3:	89 54 24 04          	mov    %edx,0x4(%esp)
801026f7:	8b 55 08             	mov    0x8(%ebp),%edx
801026fa:	89 14 24             	mov    %edx,(%esp)
801026fd:	ff d0                	call   *%eax
801026ff:	e9 1a 01 00 00       	jmp    8010281e <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80102704:	8b 45 08             	mov    0x8(%ebp),%eax
80102707:	8b 40 18             	mov    0x18(%eax),%eax
8010270a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010270d:	72 0d                	jb     8010271c <writei+0x8b>
8010270f:	8b 45 14             	mov    0x14(%ebp),%eax
80102712:	8b 55 10             	mov    0x10(%ebp),%edx
80102715:	01 d0                	add    %edx,%eax
80102717:	3b 45 10             	cmp    0x10(%ebp),%eax
8010271a:	73 0a                	jae    80102726 <writei+0x95>
    return -1;
8010271c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102721:	e9 f8 00 00 00       	jmp    8010281e <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80102726:	8b 45 14             	mov    0x14(%ebp),%eax
80102729:	8b 55 10             	mov    0x10(%ebp),%edx
8010272c:	01 d0                	add    %edx,%eax
8010272e:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102733:	76 0a                	jbe    8010273f <writei+0xae>
    return -1;
80102735:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010273a:	e9 df 00 00 00       	jmp    8010281e <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010273f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102746:	e9 9f 00 00 00       	jmp    801027ea <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010274b:	8b 45 10             	mov    0x10(%ebp),%eax
8010274e:	c1 e8 09             	shr    $0x9,%eax
80102751:	89 44 24 04          	mov    %eax,0x4(%esp)
80102755:	8b 45 08             	mov    0x8(%ebp),%eax
80102758:	89 04 24             	mov    %eax,(%esp)
8010275b:	e8 62 fb ff ff       	call   801022c2 <bmap>
80102760:	8b 55 08             	mov    0x8(%ebp),%edx
80102763:	8b 12                	mov    (%edx),%edx
80102765:	89 44 24 04          	mov    %eax,0x4(%esp)
80102769:	89 14 24             	mov    %edx,(%esp)
8010276c:	e8 35 da ff ff       	call   801001a6 <bread>
80102771:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102774:	8b 45 10             	mov    0x10(%ebp),%eax
80102777:	25 ff 01 00 00       	and    $0x1ff,%eax
8010277c:	89 c2                	mov    %eax,%edx
8010277e:	b8 00 02 00 00       	mov    $0x200,%eax
80102783:	29 d0                	sub    %edx,%eax
80102785:	89 c2                	mov    %eax,%edx
80102787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278a:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010278d:	29 c1                	sub    %eax,%ecx
8010278f:	89 c8                	mov    %ecx,%eax
80102791:	39 c2                	cmp    %eax,%edx
80102793:	0f 46 c2             	cmovbe %edx,%eax
80102796:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102799:	8b 45 10             	mov    0x10(%ebp),%eax
8010279c:	25 ff 01 00 00       	and    $0x1ff,%eax
801027a1:	8d 50 10             	lea    0x10(%eax),%edx
801027a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a7:	01 d0                	add    %edx,%eax
801027a9:	8d 50 08             	lea    0x8(%eax),%edx
801027ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027af:	89 44 24 08          	mov    %eax,0x8(%esp)
801027b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801027b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801027ba:	89 14 24             	mov    %edx,(%esp)
801027bd:	e8 3b 33 00 00       	call   80105afd <memmove>
    log_write(bp);
801027c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027c5:	89 04 24             	mov    %eax,(%esp)
801027c8:	e8 40 16 00 00       	call   80103e0d <log_write>
    brelse(bp);
801027cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027d0:	89 04 24             	mov    %eax,(%esp)
801027d3:	e8 3f da ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801027d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027db:	01 45 f4             	add    %eax,-0xc(%ebp)
801027de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027e1:	01 45 10             	add    %eax,0x10(%ebp)
801027e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027e7:	01 45 0c             	add    %eax,0xc(%ebp)
801027ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ed:	3b 45 14             	cmp    0x14(%ebp),%eax
801027f0:	0f 82 55 ff ff ff    	jb     8010274b <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801027f6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801027fa:	74 1f                	je     8010281b <writei+0x18a>
801027fc:	8b 45 08             	mov    0x8(%ebp),%eax
801027ff:	8b 40 18             	mov    0x18(%eax),%eax
80102802:	3b 45 10             	cmp    0x10(%ebp),%eax
80102805:	73 14                	jae    8010281b <writei+0x18a>
    ip->size = off;
80102807:	8b 45 08             	mov    0x8(%ebp),%eax
8010280a:	8b 55 10             	mov    0x10(%ebp),%edx
8010280d:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102810:	8b 45 08             	mov    0x8(%ebp),%eax
80102813:	89 04 24             	mov    %eax,(%esp)
80102816:	e8 3d f6 ff ff       	call   80101e58 <iupdate>
  }
  return n;
8010281b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010281e:	c9                   	leave  
8010281f:	c3                   	ret    

80102820 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102820:	55                   	push   %ebp
80102821:	89 e5                	mov    %esp,%ebp
80102823:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102826:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010282d:	00 
8010282e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102831:	89 44 24 04          	mov    %eax,0x4(%esp)
80102835:	8b 45 08             	mov    0x8(%ebp),%eax
80102838:	89 04 24             	mov    %eax,(%esp)
8010283b:	e8 60 33 00 00       	call   80105ba0 <strncmp>
}
80102840:	c9                   	leave  
80102841:	c3                   	ret    

80102842 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102842:	55                   	push   %ebp
80102843:	89 e5                	mov    %esp,%ebp
80102845:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102848:	8b 45 08             	mov    0x8(%ebp),%eax
8010284b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010284f:	66 83 f8 01          	cmp    $0x1,%ax
80102853:	74 0c                	je     80102861 <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102855:	c7 04 24 63 90 10 80 	movl   $0x80109063,(%esp)
8010285c:	e8 d9 dc ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102861:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102868:	e9 88 00 00 00       	jmp    801028f5 <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010286d:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102874:	00 
80102875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102878:	89 44 24 08          	mov    %eax,0x8(%esp)
8010287c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010287f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102883:	8b 45 08             	mov    0x8(%ebp),%eax
80102886:	89 04 24             	mov    %eax,(%esp)
80102889:	e8 9f fc ff ff       	call   8010252d <readi>
8010288e:	83 f8 10             	cmp    $0x10,%eax
80102891:	74 0c                	je     8010289f <dirlookup+0x5d>
      panic("dirlink read");
80102893:	c7 04 24 75 90 10 80 	movl   $0x80109075,(%esp)
8010289a:	e8 9b dc ff ff       	call   8010053a <panic>
    if(de.inum == 0)
8010289f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801028a3:	66 85 c0             	test   %ax,%ax
801028a6:	75 02                	jne    801028aa <dirlookup+0x68>
      continue;
801028a8:	eb 47                	jmp    801028f1 <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
801028aa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801028ad:	83 c0 02             	add    $0x2,%eax
801028b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801028b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801028b7:	89 04 24             	mov    %eax,(%esp)
801028ba:	e8 61 ff ff ff       	call   80102820 <namecmp>
801028bf:	85 c0                	test   %eax,%eax
801028c1:	75 2e                	jne    801028f1 <dirlookup+0xaf>
      // entry matches path element
      if(poff)
801028c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801028c7:	74 08                	je     801028d1 <dirlookup+0x8f>
        *poff = off;
801028c9:	8b 45 10             	mov    0x10(%ebp),%eax
801028cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801028cf:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801028d1:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801028d5:	0f b7 c0             	movzwl %ax,%eax
801028d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801028db:	8b 45 08             	mov    0x8(%ebp),%eax
801028de:	8b 00                	mov    (%eax),%eax
801028e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801028e3:	89 54 24 04          	mov    %edx,0x4(%esp)
801028e7:	89 04 24             	mov    %eax,(%esp)
801028ea:	e8 27 f6 ff ff       	call   80101f16 <iget>
801028ef:	eb 18                	jmp    80102909 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801028f1:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801028f5:	8b 45 08             	mov    0x8(%ebp),%eax
801028f8:	8b 40 18             	mov    0x18(%eax),%eax
801028fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801028fe:	0f 87 69 ff ff ff    	ja     8010286d <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102904:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102909:	c9                   	leave  
8010290a:	c3                   	ret    

8010290b <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010290b:	55                   	push   %ebp
8010290c:	89 e5                	mov    %esp,%ebp
8010290e:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102911:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102918:	00 
80102919:	8b 45 0c             	mov    0xc(%ebp),%eax
8010291c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102920:	8b 45 08             	mov    0x8(%ebp),%eax
80102923:	89 04 24             	mov    %eax,(%esp)
80102926:	e8 17 ff ff ff       	call   80102842 <dirlookup>
8010292b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010292e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102932:	74 15                	je     80102949 <dirlink+0x3e>
    iput(ip);
80102934:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102937:	89 04 24             	mov    %eax,(%esp)
8010293a:	e8 94 f8 ff ff       	call   801021d3 <iput>
    return -1;
8010293f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102944:	e9 b7 00 00 00       	jmp    80102a00 <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102949:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102950:	eb 46                	jmp    80102998 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102955:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010295c:	00 
8010295d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102961:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102964:	89 44 24 04          	mov    %eax,0x4(%esp)
80102968:	8b 45 08             	mov    0x8(%ebp),%eax
8010296b:	89 04 24             	mov    %eax,(%esp)
8010296e:	e8 ba fb ff ff       	call   8010252d <readi>
80102973:	83 f8 10             	cmp    $0x10,%eax
80102976:	74 0c                	je     80102984 <dirlink+0x79>
      panic("dirlink read");
80102978:	c7 04 24 75 90 10 80 	movl   $0x80109075,(%esp)
8010297f:	e8 b6 db ff ff       	call   8010053a <panic>
    if(de.inum == 0)
80102984:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102988:	66 85 c0             	test   %ax,%ax
8010298b:	75 02                	jne    8010298f <dirlink+0x84>
      break;
8010298d:	eb 16                	jmp    801029a5 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010298f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102992:	83 c0 10             	add    $0x10,%eax
80102995:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102998:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010299b:	8b 45 08             	mov    0x8(%ebp),%eax
8010299e:	8b 40 18             	mov    0x18(%eax),%eax
801029a1:	39 c2                	cmp    %eax,%edx
801029a3:	72 ad                	jb     80102952 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801029a5:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801029ac:	00 
801029ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801029b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801029b7:	83 c0 02             	add    $0x2,%eax
801029ba:	89 04 24             	mov    %eax,(%esp)
801029bd:	e8 34 32 00 00       	call   80105bf6 <strncpy>
  de.inum = inum;
801029c2:	8b 45 10             	mov    0x10(%ebp),%eax
801029c5:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801029c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029cc:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801029d3:	00 
801029d4:	89 44 24 08          	mov    %eax,0x8(%esp)
801029d8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801029db:	89 44 24 04          	mov    %eax,0x4(%esp)
801029df:	8b 45 08             	mov    0x8(%ebp),%eax
801029e2:	89 04 24             	mov    %eax,(%esp)
801029e5:	e8 a7 fc ff ff       	call   80102691 <writei>
801029ea:	83 f8 10             	cmp    $0x10,%eax
801029ed:	74 0c                	je     801029fb <dirlink+0xf0>
    panic("dirlink");
801029ef:	c7 04 24 82 90 10 80 	movl   $0x80109082,(%esp)
801029f6:	e8 3f db ff ff       	call   8010053a <panic>
  
  return 0;
801029fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102a00:	c9                   	leave  
80102a01:	c3                   	ret    

80102a02 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102a02:	55                   	push   %ebp
80102a03:	89 e5                	mov    %esp,%ebp
80102a05:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102a08:	eb 04                	jmp    80102a0e <skipelem+0xc>
    path++;
80102a0a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a11:	0f b6 00             	movzbl (%eax),%eax
80102a14:	3c 2f                	cmp    $0x2f,%al
80102a16:	74 f2                	je     80102a0a <skipelem+0x8>
    path++;
  if(*path == 0)
80102a18:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1b:	0f b6 00             	movzbl (%eax),%eax
80102a1e:	84 c0                	test   %al,%al
80102a20:	75 0a                	jne    80102a2c <skipelem+0x2a>
    return 0;
80102a22:	b8 00 00 00 00       	mov    $0x0,%eax
80102a27:	e9 86 00 00 00       	jmp    80102ab2 <skipelem+0xb0>
  s = path;
80102a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102a32:	eb 04                	jmp    80102a38 <skipelem+0x36>
    path++;
80102a34:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102a38:	8b 45 08             	mov    0x8(%ebp),%eax
80102a3b:	0f b6 00             	movzbl (%eax),%eax
80102a3e:	3c 2f                	cmp    $0x2f,%al
80102a40:	74 0a                	je     80102a4c <skipelem+0x4a>
80102a42:	8b 45 08             	mov    0x8(%ebp),%eax
80102a45:	0f b6 00             	movzbl (%eax),%eax
80102a48:	84 c0                	test   %al,%al
80102a4a:	75 e8                	jne    80102a34 <skipelem+0x32>
    path++;
  len = path - s;
80102a4c:	8b 55 08             	mov    0x8(%ebp),%edx
80102a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a52:	29 c2                	sub    %eax,%edx
80102a54:	89 d0                	mov    %edx,%eax
80102a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102a59:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102a5d:	7e 1c                	jle    80102a7b <skipelem+0x79>
    memmove(name, s, DIRSIZ);
80102a5f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102a66:	00 
80102a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a71:	89 04 24             	mov    %eax,(%esp)
80102a74:	e8 84 30 00 00       	call   80105afd <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102a79:	eb 2a                	jmp    80102aa5 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a85:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a89:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a8c:	89 04 24             	mov    %eax,(%esp)
80102a8f:	e8 69 30 00 00       	call   80105afd <memmove>
    name[len] = 0;
80102a94:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102a97:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a9a:	01 d0                	add    %edx,%eax
80102a9c:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102a9f:	eb 04                	jmp    80102aa5 <skipelem+0xa3>
    path++;
80102aa1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa8:	0f b6 00             	movzbl (%eax),%eax
80102aab:	3c 2f                	cmp    $0x2f,%al
80102aad:	74 f2                	je     80102aa1 <skipelem+0x9f>
    path++;
  return path;
80102aaf:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102ab2:	c9                   	leave  
80102ab3:	c3                   	ret    

80102ab4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102ab4:	55                   	push   %ebp
80102ab5:	89 e5                	mov    %esp,%ebp
80102ab7:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102aba:	8b 45 08             	mov    0x8(%ebp),%eax
80102abd:	0f b6 00             	movzbl (%eax),%eax
80102ac0:	3c 2f                	cmp    $0x2f,%al
80102ac2:	75 1c                	jne    80102ae0 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102ac4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102acb:	00 
80102acc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102ad3:	e8 3e f4 ff ff       	call   80101f16 <iget>
80102ad8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102adb:	e9 af 00 00 00       	jmp    80102b8f <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102ae0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102ae6:	8b 40 68             	mov    0x68(%eax),%eax
80102ae9:	89 04 24             	mov    %eax,(%esp)
80102aec:	e8 f7 f4 ff ff       	call   80101fe8 <idup>
80102af1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102af4:	e9 96 00 00 00       	jmp    80102b8f <namex+0xdb>
    ilock(ip);
80102af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102afc:	89 04 24             	mov    %eax,(%esp)
80102aff:	e8 16 f5 ff ff       	call   8010201a <ilock>
    if(ip->type != T_DIR){
80102b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b07:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102b0b:	66 83 f8 01          	cmp    $0x1,%ax
80102b0f:	74 15                	je     80102b26 <namex+0x72>
      iunlockput(ip);
80102b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b14:	89 04 24             	mov    %eax,(%esp)
80102b17:	e8 88 f7 ff ff       	call   801022a4 <iunlockput>
      return 0;
80102b1c:	b8 00 00 00 00       	mov    $0x0,%eax
80102b21:	e9 a3 00 00 00       	jmp    80102bc9 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102b26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102b2a:	74 1d                	je     80102b49 <namex+0x95>
80102b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2f:	0f b6 00             	movzbl (%eax),%eax
80102b32:	84 c0                	test   %al,%al
80102b34:	75 13                	jne    80102b49 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b39:	89 04 24             	mov    %eax,(%esp)
80102b3c:	e8 2d f6 ff ff       	call   8010216e <iunlock>
      return ip;
80102b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b44:	e9 80 00 00 00       	jmp    80102bc9 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102b49:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102b50:	00 
80102b51:	8b 45 10             	mov    0x10(%ebp),%eax
80102b54:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b5b:	89 04 24             	mov    %eax,(%esp)
80102b5e:	e8 df fc ff ff       	call   80102842 <dirlookup>
80102b63:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102b66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102b6a:	75 12                	jne    80102b7e <namex+0xca>
      iunlockput(ip);
80102b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b6f:	89 04 24             	mov    %eax,(%esp)
80102b72:	e8 2d f7 ff ff       	call   801022a4 <iunlockput>
      return 0;
80102b77:	b8 00 00 00 00       	mov    $0x0,%eax
80102b7c:	eb 4b                	jmp    80102bc9 <namex+0x115>
    }
    iunlockput(ip);
80102b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b81:	89 04 24             	mov    %eax,(%esp)
80102b84:	e8 1b f7 ff ff       	call   801022a4 <iunlockput>
    ip = next;
80102b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102b8f:	8b 45 10             	mov    0x10(%ebp),%eax
80102b92:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b96:	8b 45 08             	mov    0x8(%ebp),%eax
80102b99:	89 04 24             	mov    %eax,(%esp)
80102b9c:	e8 61 fe ff ff       	call   80102a02 <skipelem>
80102ba1:	89 45 08             	mov    %eax,0x8(%ebp)
80102ba4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102ba8:	0f 85 4b ff ff ff    	jne    80102af9 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102bae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102bb2:	74 12                	je     80102bc6 <namex+0x112>
    iput(ip);
80102bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb7:	89 04 24             	mov    %eax,(%esp)
80102bba:	e8 14 f6 ff ff       	call   801021d3 <iput>
    return 0;
80102bbf:	b8 00 00 00 00       	mov    $0x0,%eax
80102bc4:	eb 03                	jmp    80102bc9 <namex+0x115>
  }
  return ip;
80102bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102bc9:	c9                   	leave  
80102bca:	c3                   	ret    

80102bcb <namei>:

struct inode*
namei(char *path)
{
80102bcb:	55                   	push   %ebp
80102bcc:	89 e5                	mov    %esp,%ebp
80102bce:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102bd1:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102bd4:	89 44 24 08          	mov    %eax,0x8(%esp)
80102bd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102bdf:	00 
80102be0:	8b 45 08             	mov    0x8(%ebp),%eax
80102be3:	89 04 24             	mov    %eax,(%esp)
80102be6:	e8 c9 fe ff ff       	call   80102ab4 <namex>
}
80102beb:	c9                   	leave  
80102bec:	c3                   	ret    

80102bed <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102bed:	55                   	push   %ebp
80102bee:	89 e5                	mov    %esp,%ebp
80102bf0:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf6:	89 44 24 08          	mov    %eax,0x8(%esp)
80102bfa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102c01:	00 
80102c02:	8b 45 08             	mov    0x8(%ebp),%eax
80102c05:	89 04 24             	mov    %eax,(%esp)
80102c08:	e8 a7 fe ff ff       	call   80102ab4 <namex>
}
80102c0d:	c9                   	leave  
80102c0e:	c3                   	ret    

80102c0f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c0f:	55                   	push   %ebp
80102c10:	89 e5                	mov    %esp,%ebp
80102c12:	83 ec 14             	sub    $0x14,%esp
80102c15:	8b 45 08             	mov    0x8(%ebp),%eax
80102c18:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c1c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c20:	89 c2                	mov    %eax,%edx
80102c22:	ec                   	in     (%dx),%al
80102c23:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c26:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c2a:	c9                   	leave  
80102c2b:	c3                   	ret    

80102c2c <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102c2c:	55                   	push   %ebp
80102c2d:	89 e5                	mov    %esp,%ebp
80102c2f:	57                   	push   %edi
80102c30:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102c31:	8b 55 08             	mov    0x8(%ebp),%edx
80102c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102c37:	8b 45 10             	mov    0x10(%ebp),%eax
80102c3a:	89 cb                	mov    %ecx,%ebx
80102c3c:	89 df                	mov    %ebx,%edi
80102c3e:	89 c1                	mov    %eax,%ecx
80102c40:	fc                   	cld    
80102c41:	f3 6d                	rep insl (%dx),%es:(%edi)
80102c43:	89 c8                	mov    %ecx,%eax
80102c45:	89 fb                	mov    %edi,%ebx
80102c47:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102c4a:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102c4d:	5b                   	pop    %ebx
80102c4e:	5f                   	pop    %edi
80102c4f:	5d                   	pop    %ebp
80102c50:	c3                   	ret    

80102c51 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102c51:	55                   	push   %ebp
80102c52:	89 e5                	mov    %esp,%ebp
80102c54:	83 ec 08             	sub    $0x8,%esp
80102c57:	8b 55 08             	mov    0x8(%ebp),%edx
80102c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c5d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102c61:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c64:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102c68:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102c6c:	ee                   	out    %al,(%dx)
}
80102c6d:	c9                   	leave  
80102c6e:	c3                   	ret    

80102c6f <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102c6f:	55                   	push   %ebp
80102c70:	89 e5                	mov    %esp,%ebp
80102c72:	56                   	push   %esi
80102c73:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102c74:	8b 55 08             	mov    0x8(%ebp),%edx
80102c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102c7a:	8b 45 10             	mov    0x10(%ebp),%eax
80102c7d:	89 cb                	mov    %ecx,%ebx
80102c7f:	89 de                	mov    %ebx,%esi
80102c81:	89 c1                	mov    %eax,%ecx
80102c83:	fc                   	cld    
80102c84:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102c86:	89 c8                	mov    %ecx,%eax
80102c88:	89 f3                	mov    %esi,%ebx
80102c8a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102c8d:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102c90:	5b                   	pop    %ebx
80102c91:	5e                   	pop    %esi
80102c92:	5d                   	pop    %ebp
80102c93:	c3                   	ret    

80102c94 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102c94:	55                   	push   %ebp
80102c95:	89 e5                	mov    %esp,%ebp
80102c97:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102c9a:	90                   	nop
80102c9b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102ca2:	e8 68 ff ff ff       	call   80102c0f <inb>
80102ca7:	0f b6 c0             	movzbl %al,%eax
80102caa:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102cad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cb0:	25 c0 00 00 00       	and    $0xc0,%eax
80102cb5:	83 f8 40             	cmp    $0x40,%eax
80102cb8:	75 e1                	jne    80102c9b <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102cba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102cbe:	74 11                	je     80102cd1 <idewait+0x3d>
80102cc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cc3:	83 e0 21             	and    $0x21,%eax
80102cc6:	85 c0                	test   %eax,%eax
80102cc8:	74 07                	je     80102cd1 <idewait+0x3d>
    return -1;
80102cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ccf:	eb 05                	jmp    80102cd6 <idewait+0x42>
  return 0;
80102cd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102cd6:	c9                   	leave  
80102cd7:	c3                   	ret    

80102cd8 <ideinit>:

void
ideinit(void)
{
80102cd8:	55                   	push   %ebp
80102cd9:	89 e5                	mov    %esp,%ebp
80102cdb:	83 ec 28             	sub    $0x28,%esp
  int i;
  
  initlock(&idelock, "ide");
80102cde:	c7 44 24 04 8a 90 10 	movl   $0x8010908a,0x4(%esp)
80102ce5:	80 
80102ce6:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102ced:	e8 c7 2a 00 00       	call   801057b9 <initlock>
  picenable(IRQ_IDE);
80102cf2:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102cf9:	e8 a3 18 00 00       	call   801045a1 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102cfe:	a1 60 41 11 80       	mov    0x80114160,%eax
80102d03:	83 e8 01             	sub    $0x1,%eax
80102d06:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d0a:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102d11:	e8 43 04 00 00       	call   80103159 <ioapicenable>
  idewait(0);
80102d16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102d1d:	e8 72 ff ff ff       	call   80102c94 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102d22:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102d29:	00 
80102d2a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102d31:	e8 1b ff ff ff       	call   80102c51 <outb>
  for(i=0; i<1000; i++){
80102d36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102d3d:	eb 20                	jmp    80102d5f <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102d3f:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102d46:	e8 c4 fe ff ff       	call   80102c0f <inb>
80102d4b:	84 c0                	test   %al,%al
80102d4d:	74 0c                	je     80102d5b <ideinit+0x83>
      havedisk1 = 1;
80102d4f:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102d56:	00 00 00 
      break;
80102d59:	eb 0d                	jmp    80102d68 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102d5b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102d5f:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102d66:	7e d7                	jle    80102d3f <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102d68:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102d6f:	00 
80102d70:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102d77:	e8 d5 fe ff ff       	call   80102c51 <outb>
}
80102d7c:	c9                   	leave  
80102d7d:	c3                   	ret    

80102d7e <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102d7e:	55                   	push   %ebp
80102d7f:	89 e5                	mov    %esp,%ebp
80102d81:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102d84:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102d88:	75 0c                	jne    80102d96 <idestart+0x18>
    panic("idestart");
80102d8a:	c7 04 24 8e 90 10 80 	movl   $0x8010908e,(%esp)
80102d91:	e8 a4 d7 ff ff       	call   8010053a <panic>
  if(b->blockno >= FSSIZE)
80102d96:	8b 45 08             	mov    0x8(%ebp),%eax
80102d99:	8b 40 08             	mov    0x8(%eax),%eax
80102d9c:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102da1:	76 0c                	jbe    80102daf <idestart+0x31>
    panic("incorrect blockno");
80102da3:	c7 04 24 97 90 10 80 	movl   $0x80109097,(%esp)
80102daa:	e8 8b d7 ff ff       	call   8010053a <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102daf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102db6:	8b 45 08             	mov    0x8(%ebp),%eax
80102db9:	8b 50 08             	mov    0x8(%eax),%edx
80102dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dbf:	0f af c2             	imul   %edx,%eax
80102dc2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102dc5:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102dc9:	7e 0c                	jle    80102dd7 <idestart+0x59>
80102dcb:	c7 04 24 8e 90 10 80 	movl   $0x8010908e,(%esp)
80102dd2:	e8 63 d7 ff ff       	call   8010053a <panic>
  
  idewait(0);
80102dd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102dde:	e8 b1 fe ff ff       	call   80102c94 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102de3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102dea:	00 
80102deb:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102df2:	e8 5a fe ff ff       	call   80102c51 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dfa:	0f b6 c0             	movzbl %al,%eax
80102dfd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e01:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102e08:	e8 44 fe ff ff       	call   80102c51 <outb>
  outb(0x1f3, sector & 0xff);
80102e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e10:	0f b6 c0             	movzbl %al,%eax
80102e13:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e17:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102e1e:	e8 2e fe ff ff       	call   80102c51 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e26:	c1 f8 08             	sar    $0x8,%eax
80102e29:	0f b6 c0             	movzbl %al,%eax
80102e2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e30:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102e37:	e8 15 fe ff ff       	call   80102c51 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e3f:	c1 f8 10             	sar    $0x10,%eax
80102e42:	0f b6 c0             	movzbl %al,%eax
80102e45:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e49:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102e50:	e8 fc fd ff ff       	call   80102c51 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102e55:	8b 45 08             	mov    0x8(%ebp),%eax
80102e58:	8b 40 04             	mov    0x4(%eax),%eax
80102e5b:	83 e0 01             	and    $0x1,%eax
80102e5e:	c1 e0 04             	shl    $0x4,%eax
80102e61:	89 c2                	mov    %eax,%edx
80102e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e66:	c1 f8 18             	sar    $0x18,%eax
80102e69:	83 e0 0f             	and    $0xf,%eax
80102e6c:	09 d0                	or     %edx,%eax
80102e6e:	83 c8 e0             	or     $0xffffffe0,%eax
80102e71:	0f b6 c0             	movzbl %al,%eax
80102e74:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e78:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102e7f:	e8 cd fd ff ff       	call   80102c51 <outb>
  if(b->flags & B_DIRTY){
80102e84:	8b 45 08             	mov    0x8(%ebp),%eax
80102e87:	8b 00                	mov    (%eax),%eax
80102e89:	83 e0 04             	and    $0x4,%eax
80102e8c:	85 c0                	test   %eax,%eax
80102e8e:	74 34                	je     80102ec4 <idestart+0x146>
    outb(0x1f7, IDE_CMD_WRITE);
80102e90:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102e97:	00 
80102e98:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102e9f:	e8 ad fd ff ff       	call   80102c51 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102ea4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ea7:	83 c0 18             	add    $0x18,%eax
80102eaa:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102eb1:	00 
80102eb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80102eb6:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102ebd:	e8 ad fd ff ff       	call   80102c6f <outsl>
80102ec2:	eb 14                	jmp    80102ed8 <idestart+0x15a>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102ec4:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102ecb:	00 
80102ecc:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102ed3:	e8 79 fd ff ff       	call   80102c51 <outb>
  }
}
80102ed8:	c9                   	leave  
80102ed9:	c3                   	ret    

80102eda <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102eda:	55                   	push   %ebp
80102edb:	89 e5                	mov    %esp,%ebp
80102edd:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102ee0:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102ee7:	e8 ee 28 00 00       	call   801057da <acquire>
  if((b = idequeue) == 0){
80102eec:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102ef1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ef4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ef8:	75 11                	jne    80102f0b <ideintr+0x31>
    release(&idelock);
80102efa:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102f01:	e8 36 29 00 00       	call   8010583c <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102f06:	e9 90 00 00 00       	jmp    80102f9b <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f0e:	8b 40 14             	mov    0x14(%eax),%eax
80102f11:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f19:	8b 00                	mov    (%eax),%eax
80102f1b:	83 e0 04             	and    $0x4,%eax
80102f1e:	85 c0                	test   %eax,%eax
80102f20:	75 2e                	jne    80102f50 <ideintr+0x76>
80102f22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102f29:	e8 66 fd ff ff       	call   80102c94 <idewait>
80102f2e:	85 c0                	test   %eax,%eax
80102f30:	78 1e                	js     80102f50 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f35:	83 c0 18             	add    $0x18,%eax
80102f38:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102f3f:	00 
80102f40:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f44:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102f4b:	e8 dc fc ff ff       	call   80102c2c <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f53:	8b 00                	mov    (%eax),%eax
80102f55:	83 c8 02             	or     $0x2,%eax
80102f58:	89 c2                	mov    %eax,%edx
80102f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f5d:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f62:	8b 00                	mov    (%eax),%eax
80102f64:	83 e0 fb             	and    $0xfffffffb,%eax
80102f67:	89 c2                	mov    %eax,%edx
80102f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f6c:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f71:	89 04 24             	mov    %eax,(%esp)
80102f74:	e8 ee 25 00 00       	call   80105567 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102f79:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102f7e:	85 c0                	test   %eax,%eax
80102f80:	74 0d                	je     80102f8f <ideintr+0xb5>
    idestart(idequeue);
80102f82:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102f87:	89 04 24             	mov    %eax,(%esp)
80102f8a:	e8 ef fd ff ff       	call   80102d7e <idestart>

  release(&idelock);
80102f8f:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102f96:	e8 a1 28 00 00       	call   8010583c <release>
}
80102f9b:	c9                   	leave  
80102f9c:	c3                   	ret    

80102f9d <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102f9d:	55                   	push   %ebp
80102f9e:	89 e5                	mov    %esp,%ebp
80102fa0:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80102fa6:	8b 00                	mov    (%eax),%eax
80102fa8:	83 e0 01             	and    $0x1,%eax
80102fab:	85 c0                	test   %eax,%eax
80102fad:	75 0c                	jne    80102fbb <iderw+0x1e>
    panic("iderw: buf not busy");
80102faf:	c7 04 24 a9 90 10 80 	movl   $0x801090a9,(%esp)
80102fb6:	e8 7f d5 ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102fbb:	8b 45 08             	mov    0x8(%ebp),%eax
80102fbe:	8b 00                	mov    (%eax),%eax
80102fc0:	83 e0 06             	and    $0x6,%eax
80102fc3:	83 f8 02             	cmp    $0x2,%eax
80102fc6:	75 0c                	jne    80102fd4 <iderw+0x37>
    panic("iderw: nothing to do");
80102fc8:	c7 04 24 bd 90 10 80 	movl   $0x801090bd,(%esp)
80102fcf:	e8 66 d5 ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
80102fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80102fd7:	8b 40 04             	mov    0x4(%eax),%eax
80102fda:	85 c0                	test   %eax,%eax
80102fdc:	74 15                	je     80102ff3 <iderw+0x56>
80102fde:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102fe3:	85 c0                	test   %eax,%eax
80102fe5:	75 0c                	jne    80102ff3 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102fe7:	c7 04 24 d2 90 10 80 	movl   $0x801090d2,(%esp)
80102fee:	e8 47 d5 ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102ff3:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102ffa:	e8 db 27 00 00       	call   801057da <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102fff:	8b 45 08             	mov    0x8(%ebp),%eax
80103002:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80103009:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
80103010:	eb 0b                	jmp    8010301d <iderw+0x80>
80103012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103015:	8b 00                	mov    (%eax),%eax
80103017:	83 c0 14             	add    $0x14,%eax
8010301a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010301d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103020:	8b 00                	mov    (%eax),%eax
80103022:	85 c0                	test   %eax,%eax
80103024:	75 ec                	jne    80103012 <iderw+0x75>
    ;
  *pp = b;
80103026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103029:	8b 55 08             	mov    0x8(%ebp),%edx
8010302c:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
8010302e:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80103033:	3b 45 08             	cmp    0x8(%ebp),%eax
80103036:	75 0d                	jne    80103045 <iderw+0xa8>
    idestart(b);
80103038:	8b 45 08             	mov    0x8(%ebp),%eax
8010303b:	89 04 24             	mov    %eax,(%esp)
8010303e:	e8 3b fd ff ff       	call   80102d7e <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80103043:	eb 15                	jmp    8010305a <iderw+0xbd>
80103045:	eb 13                	jmp    8010305a <iderw+0xbd>
    sleep(b, &idelock);
80103047:	c7 44 24 04 00 c6 10 	movl   $0x8010c600,0x4(%esp)
8010304e:	80 
8010304f:	8b 45 08             	mov    0x8(%ebp),%eax
80103052:	89 04 24             	mov    %eax,(%esp)
80103055:	e8 31 24 00 00       	call   8010548b <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010305a:	8b 45 08             	mov    0x8(%ebp),%eax
8010305d:	8b 00                	mov    (%eax),%eax
8010305f:	83 e0 06             	and    $0x6,%eax
80103062:	83 f8 02             	cmp    $0x2,%eax
80103065:	75 e0                	jne    80103047 <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
80103067:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
8010306e:	e8 c9 27 00 00       	call   8010583c <release>
}
80103073:	c9                   	leave  
80103074:	c3                   	ret    

80103075 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80103075:	55                   	push   %ebp
80103076:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103078:	a1 34 3a 11 80       	mov    0x80113a34,%eax
8010307d:	8b 55 08             	mov    0x8(%ebp),%edx
80103080:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80103082:	a1 34 3a 11 80       	mov    0x80113a34,%eax
80103087:	8b 40 10             	mov    0x10(%eax),%eax
}
8010308a:	5d                   	pop    %ebp
8010308b:	c3                   	ret    

8010308c <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010308c:	55                   	push   %ebp
8010308d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010308f:	a1 34 3a 11 80       	mov    0x80113a34,%eax
80103094:	8b 55 08             	mov    0x8(%ebp),%edx
80103097:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80103099:	a1 34 3a 11 80       	mov    0x80113a34,%eax
8010309e:	8b 55 0c             	mov    0xc(%ebp),%edx
801030a1:	89 50 10             	mov    %edx,0x10(%eax)
}
801030a4:	5d                   	pop    %ebp
801030a5:	c3                   	ret    

801030a6 <ioapicinit>:

void
ioapicinit(void)
{
801030a6:	55                   	push   %ebp
801030a7:	89 e5                	mov    %esp,%ebp
801030a9:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801030ac:	a1 64 3b 11 80       	mov    0x80113b64,%eax
801030b1:	85 c0                	test   %eax,%eax
801030b3:	75 05                	jne    801030ba <ioapicinit+0x14>
    return;
801030b5:	e9 9d 00 00 00       	jmp    80103157 <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
801030ba:	c7 05 34 3a 11 80 00 	movl   $0xfec00000,0x80113a34
801030c1:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801030c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801030cb:	e8 a5 ff ff ff       	call   80103075 <ioapicread>
801030d0:	c1 e8 10             	shr    $0x10,%eax
801030d3:	25 ff 00 00 00       	and    $0xff,%eax
801030d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801030db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801030e2:	e8 8e ff ff ff       	call   80103075 <ioapicread>
801030e7:	c1 e8 18             	shr    $0x18,%eax
801030ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801030ed:	0f b6 05 60 3b 11 80 	movzbl 0x80113b60,%eax
801030f4:	0f b6 c0             	movzbl %al,%eax
801030f7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801030fa:	74 0c                	je     80103108 <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801030fc:	c7 04 24 f0 90 10 80 	movl   $0x801090f0,(%esp)
80103103:	e8 98 d2 ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80103108:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010310f:	eb 3e                	jmp    8010314f <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80103111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103114:	83 c0 20             	add    $0x20,%eax
80103117:	0d 00 00 01 00       	or     $0x10000,%eax
8010311c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010311f:	83 c2 08             	add    $0x8,%edx
80103122:	01 d2                	add    %edx,%edx
80103124:	89 44 24 04          	mov    %eax,0x4(%esp)
80103128:	89 14 24             	mov    %edx,(%esp)
8010312b:	e8 5c ff ff ff       	call   8010308c <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80103130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103133:	83 c0 08             	add    $0x8,%eax
80103136:	01 c0                	add    %eax,%eax
80103138:	83 c0 01             	add    $0x1,%eax
8010313b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103142:	00 
80103143:	89 04 24             	mov    %eax,(%esp)
80103146:	e8 41 ff ff ff       	call   8010308c <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010314b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010314f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103152:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80103155:	7e ba                	jle    80103111 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80103157:	c9                   	leave  
80103158:	c3                   	ret    

80103159 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80103159:	55                   	push   %ebp
8010315a:	89 e5                	mov    %esp,%ebp
8010315c:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
8010315f:	a1 64 3b 11 80       	mov    0x80113b64,%eax
80103164:	85 c0                	test   %eax,%eax
80103166:	75 02                	jne    8010316a <ioapicenable+0x11>
    return;
80103168:	eb 37                	jmp    801031a1 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010316a:	8b 45 08             	mov    0x8(%ebp),%eax
8010316d:	83 c0 20             	add    $0x20,%eax
80103170:	8b 55 08             	mov    0x8(%ebp),%edx
80103173:	83 c2 08             	add    $0x8,%edx
80103176:	01 d2                	add    %edx,%edx
80103178:	89 44 24 04          	mov    %eax,0x4(%esp)
8010317c:	89 14 24             	mov    %edx,(%esp)
8010317f:	e8 08 ff ff ff       	call   8010308c <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80103184:	8b 45 0c             	mov    0xc(%ebp),%eax
80103187:	c1 e0 18             	shl    $0x18,%eax
8010318a:	8b 55 08             	mov    0x8(%ebp),%edx
8010318d:	83 c2 08             	add    $0x8,%edx
80103190:	01 d2                	add    %edx,%edx
80103192:	83 c2 01             	add    $0x1,%edx
80103195:	89 44 24 04          	mov    %eax,0x4(%esp)
80103199:	89 14 24             	mov    %edx,(%esp)
8010319c:	e8 eb fe ff ff       	call   8010308c <ioapicwrite>
}
801031a1:	c9                   	leave  
801031a2:	c3                   	ret    

801031a3 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801031a3:	55                   	push   %ebp
801031a4:	89 e5                	mov    %esp,%ebp
801031a6:	8b 45 08             	mov    0x8(%ebp),%eax
801031a9:	05 00 00 00 80       	add    $0x80000000,%eax
801031ae:	5d                   	pop    %ebp
801031af:	c3                   	ret    

801031b0 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801031b0:	55                   	push   %ebp
801031b1:	89 e5                	mov    %esp,%ebp
801031b3:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801031b6:	c7 44 24 04 22 91 10 	movl   $0x80109122,0x4(%esp)
801031bd:	80 
801031be:	c7 04 24 40 3a 11 80 	movl   $0x80113a40,(%esp)
801031c5:	e8 ef 25 00 00       	call   801057b9 <initlock>
  kmem.use_lock = 0;
801031ca:	c7 05 74 3a 11 80 00 	movl   $0x0,0x80113a74
801031d1:	00 00 00 
  freerange(vstart, vend);
801031d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801031d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801031db:	8b 45 08             	mov    0x8(%ebp),%eax
801031de:	89 04 24             	mov    %eax,(%esp)
801031e1:	e8 26 00 00 00       	call   8010320c <freerange>
}
801031e6:	c9                   	leave  
801031e7:	c3                   	ret    

801031e8 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801031e8:	55                   	push   %ebp
801031e9:	89 e5                	mov    %esp,%ebp
801031eb:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
801031ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801031f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801031f5:	8b 45 08             	mov    0x8(%ebp),%eax
801031f8:	89 04 24             	mov    %eax,(%esp)
801031fb:	e8 0c 00 00 00       	call   8010320c <freerange>
  kmem.use_lock = 1;
80103200:	c7 05 74 3a 11 80 01 	movl   $0x1,0x80113a74
80103207:	00 00 00 
}
8010320a:	c9                   	leave  
8010320b:	c3                   	ret    

8010320c <freerange>:

void
freerange(void *vstart, void *vend)
{
8010320c:	55                   	push   %ebp
8010320d:	89 e5                	mov    %esp,%ebp
8010320f:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80103212:	8b 45 08             	mov    0x8(%ebp),%eax
80103215:	05 ff 0f 00 00       	add    $0xfff,%eax
8010321a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010321f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80103222:	eb 12                	jmp    80103236 <freerange+0x2a>
    kfree(p);
80103224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103227:	89 04 24             	mov    %eax,(%esp)
8010322a:	e8 16 00 00 00       	call   80103245 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010322f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80103236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103239:	05 00 10 00 00       	add    $0x1000,%eax
8010323e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103241:	76 e1                	jbe    80103224 <freerange+0x18>
    kfree(p);
}
80103243:	c9                   	leave  
80103244:	c3                   	ret    

80103245 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80103245:	55                   	push   %ebp
80103246:	89 e5                	mov    %esp,%ebp
80103248:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
8010324b:	8b 45 08             	mov    0x8(%ebp),%eax
8010324e:	25 ff 0f 00 00       	and    $0xfff,%eax
80103253:	85 c0                	test   %eax,%eax
80103255:	75 1b                	jne    80103272 <kfree+0x2d>
80103257:	81 7d 08 5c 6d 11 80 	cmpl   $0x80116d5c,0x8(%ebp)
8010325e:	72 12                	jb     80103272 <kfree+0x2d>
80103260:	8b 45 08             	mov    0x8(%ebp),%eax
80103263:	89 04 24             	mov    %eax,(%esp)
80103266:	e8 38 ff ff ff       	call   801031a3 <v2p>
8010326b:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103270:	76 0c                	jbe    8010327e <kfree+0x39>
    panic("kfree");
80103272:	c7 04 24 27 91 10 80 	movl   $0x80109127,(%esp)
80103279:	e8 bc d2 ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010327e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80103285:	00 
80103286:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010328d:	00 
8010328e:	8b 45 08             	mov    0x8(%ebp),%eax
80103291:	89 04 24             	mov    %eax,(%esp)
80103294:	e8 95 27 00 00       	call   80105a2e <memset>

  if(kmem.use_lock)
80103299:	a1 74 3a 11 80       	mov    0x80113a74,%eax
8010329e:	85 c0                	test   %eax,%eax
801032a0:	74 0c                	je     801032ae <kfree+0x69>
    acquire(&kmem.lock);
801032a2:	c7 04 24 40 3a 11 80 	movl   $0x80113a40,(%esp)
801032a9:	e8 2c 25 00 00       	call   801057da <acquire>
  r = (struct run*)v;
801032ae:	8b 45 08             	mov    0x8(%ebp),%eax
801032b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801032b4:	8b 15 78 3a 11 80    	mov    0x80113a78,%edx
801032ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032bd:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801032bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032c2:	a3 78 3a 11 80       	mov    %eax,0x80113a78
  if(kmem.use_lock)
801032c7:	a1 74 3a 11 80       	mov    0x80113a74,%eax
801032cc:	85 c0                	test   %eax,%eax
801032ce:	74 0c                	je     801032dc <kfree+0x97>
    release(&kmem.lock);
801032d0:	c7 04 24 40 3a 11 80 	movl   $0x80113a40,(%esp)
801032d7:	e8 60 25 00 00       	call   8010583c <release>
}
801032dc:	c9                   	leave  
801032dd:	c3                   	ret    

801032de <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801032de:	55                   	push   %ebp
801032df:	89 e5                	mov    %esp,%ebp
801032e1:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
801032e4:	a1 74 3a 11 80       	mov    0x80113a74,%eax
801032e9:	85 c0                	test   %eax,%eax
801032eb:	74 0c                	je     801032f9 <kalloc+0x1b>
    acquire(&kmem.lock);
801032ed:	c7 04 24 40 3a 11 80 	movl   $0x80113a40,(%esp)
801032f4:	e8 e1 24 00 00       	call   801057da <acquire>
  r = kmem.freelist;
801032f9:	a1 78 3a 11 80       	mov    0x80113a78,%eax
801032fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103301:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103305:	74 0a                	je     80103311 <kalloc+0x33>
    kmem.freelist = r->next;
80103307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010330a:	8b 00                	mov    (%eax),%eax
8010330c:	a3 78 3a 11 80       	mov    %eax,0x80113a78
  if(kmem.use_lock)
80103311:	a1 74 3a 11 80       	mov    0x80113a74,%eax
80103316:	85 c0                	test   %eax,%eax
80103318:	74 0c                	je     80103326 <kalloc+0x48>
    release(&kmem.lock);
8010331a:	c7 04 24 40 3a 11 80 	movl   $0x80113a40,(%esp)
80103321:	e8 16 25 00 00       	call   8010583c <release>
  return (char*)r;
80103326:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103329:	c9                   	leave  
8010332a:	c3                   	ret    

8010332b <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010332b:	55                   	push   %ebp
8010332c:	89 e5                	mov    %esp,%ebp
8010332e:	83 ec 14             	sub    $0x14,%esp
80103331:	8b 45 08             	mov    0x8(%ebp),%eax
80103334:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103338:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010333c:	89 c2                	mov    %eax,%edx
8010333e:	ec                   	in     (%dx),%al
8010333f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103342:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103346:	c9                   	leave  
80103347:	c3                   	ret    

80103348 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80103348:	55                   	push   %ebp
80103349:	89 e5                	mov    %esp,%ebp
8010334b:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
8010334e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103355:	e8 d1 ff ff ff       	call   8010332b <inb>
8010335a:	0f b6 c0             	movzbl %al,%eax
8010335d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80103360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103363:	83 e0 01             	and    $0x1,%eax
80103366:	85 c0                	test   %eax,%eax
80103368:	75 0a                	jne    80103374 <kbdgetc+0x2c>
    return -1;
8010336a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010336f:	e9 25 01 00 00       	jmp    80103499 <kbdgetc+0x151>
  data = inb(KBDATAP);
80103374:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
8010337b:	e8 ab ff ff ff       	call   8010332b <inb>
80103380:	0f b6 c0             	movzbl %al,%eax
80103383:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103386:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010338d:	75 17                	jne    801033a6 <kbdgetc+0x5e>
    shift |= E0ESC;
8010338f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103394:	83 c8 40             	or     $0x40,%eax
80103397:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
8010339c:	b8 00 00 00 00       	mov    $0x0,%eax
801033a1:	e9 f3 00 00 00       	jmp    80103499 <kbdgetc+0x151>
  } else if(data & 0x80){
801033a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801033a9:	25 80 00 00 00       	and    $0x80,%eax
801033ae:	85 c0                	test   %eax,%eax
801033b0:	74 45                	je     801033f7 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801033b2:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801033b7:	83 e0 40             	and    $0x40,%eax
801033ba:	85 c0                	test   %eax,%eax
801033bc:	75 08                	jne    801033c6 <kbdgetc+0x7e>
801033be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801033c1:	83 e0 7f             	and    $0x7f,%eax
801033c4:	eb 03                	jmp    801033c9 <kbdgetc+0x81>
801033c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801033c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801033cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801033cf:	05 20 a0 10 80       	add    $0x8010a020,%eax
801033d4:	0f b6 00             	movzbl (%eax),%eax
801033d7:	83 c8 40             	or     $0x40,%eax
801033da:	0f b6 c0             	movzbl %al,%eax
801033dd:	f7 d0                	not    %eax
801033df:	89 c2                	mov    %eax,%edx
801033e1:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801033e6:	21 d0                	and    %edx,%eax
801033e8:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
801033ed:	b8 00 00 00 00       	mov    $0x0,%eax
801033f2:	e9 a2 00 00 00       	jmp    80103499 <kbdgetc+0x151>
  } else if(shift & E0ESC){
801033f7:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801033fc:	83 e0 40             	and    $0x40,%eax
801033ff:	85 c0                	test   %eax,%eax
80103401:	74 14                	je     80103417 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103403:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010340a:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010340f:	83 e0 bf             	and    $0xffffffbf,%eax
80103412:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80103417:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010341a:	05 20 a0 10 80       	add    $0x8010a020,%eax
8010341f:	0f b6 00             	movzbl (%eax),%eax
80103422:	0f b6 d0             	movzbl %al,%edx
80103425:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010342a:	09 d0                	or     %edx,%eax
8010342c:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80103431:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103434:	05 20 a1 10 80       	add    $0x8010a120,%eax
80103439:	0f b6 00             	movzbl (%eax),%eax
8010343c:	0f b6 d0             	movzbl %al,%edx
8010343f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103444:	31 d0                	xor    %edx,%eax
80103446:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
8010344b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103450:	83 e0 03             	and    $0x3,%eax
80103453:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
8010345a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010345d:	01 d0                	add    %edx,%eax
8010345f:	0f b6 00             	movzbl (%eax),%eax
80103462:	0f b6 c0             	movzbl %al,%eax
80103465:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103468:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010346d:	83 e0 08             	and    $0x8,%eax
80103470:	85 c0                	test   %eax,%eax
80103472:	74 22                	je     80103496 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80103474:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103478:	76 0c                	jbe    80103486 <kbdgetc+0x13e>
8010347a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010347e:	77 06                	ja     80103486 <kbdgetc+0x13e>
      c += 'A' - 'a';
80103480:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103484:	eb 10                	jmp    80103496 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80103486:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010348a:	76 0a                	jbe    80103496 <kbdgetc+0x14e>
8010348c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103490:	77 04                	ja     80103496 <kbdgetc+0x14e>
      c += 'a' - 'A';
80103492:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103496:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103499:	c9                   	leave  
8010349a:	c3                   	ret    

8010349b <kbdintr>:

void
kbdintr(void)
{
8010349b:	55                   	push   %ebp
8010349c:	89 e5                	mov    %esp,%ebp
8010349e:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
801034a1:	c7 04 24 48 33 10 80 	movl   $0x80103348,(%esp)
801034a8:	e8 17 d7 ff ff       	call   80100bc4 <consoleintr>
}
801034ad:	c9                   	leave  
801034ae:	c3                   	ret    

801034af <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801034af:	55                   	push   %ebp
801034b0:	89 e5                	mov    %esp,%ebp
801034b2:	83 ec 14             	sub    $0x14,%esp
801034b5:	8b 45 08             	mov    0x8(%ebp),%eax
801034b8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801034bc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801034c0:	89 c2                	mov    %eax,%edx
801034c2:	ec                   	in     (%dx),%al
801034c3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801034c6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801034ca:	c9                   	leave  
801034cb:	c3                   	ret    

801034cc <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801034cc:	55                   	push   %ebp
801034cd:	89 e5                	mov    %esp,%ebp
801034cf:	83 ec 08             	sub    $0x8,%esp
801034d2:	8b 55 08             	mov    0x8(%ebp),%edx
801034d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801034d8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801034dc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801034df:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801034e3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801034e7:	ee                   	out    %al,(%dx)
}
801034e8:	c9                   	leave  
801034e9:	c3                   	ret    

801034ea <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801034ea:	55                   	push   %ebp
801034eb:	89 e5                	mov    %esp,%ebp
801034ed:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801034f0:	9c                   	pushf  
801034f1:	58                   	pop    %eax
801034f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801034f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801034f8:	c9                   	leave  
801034f9:	c3                   	ret    

801034fa <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801034fa:	55                   	push   %ebp
801034fb:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801034fd:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
80103502:	8b 55 08             	mov    0x8(%ebp),%edx
80103505:	c1 e2 02             	shl    $0x2,%edx
80103508:	01 c2                	add    %eax,%edx
8010350a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010350d:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010350f:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
80103514:	83 c0 20             	add    $0x20,%eax
80103517:	8b 00                	mov    (%eax),%eax
}
80103519:	5d                   	pop    %ebp
8010351a:	c3                   	ret    

8010351b <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
8010351b:	55                   	push   %ebp
8010351c:	89 e5                	mov    %esp,%ebp
8010351e:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80103521:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
80103526:	85 c0                	test   %eax,%eax
80103528:	75 05                	jne    8010352f <lapicinit+0x14>
    return;
8010352a:	e9 43 01 00 00       	jmp    80103672 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010352f:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80103536:	00 
80103537:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
8010353e:	e8 b7 ff ff ff       	call   801034fa <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103543:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
8010354a:	00 
8010354b:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103552:	e8 a3 ff ff ff       	call   801034fa <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103557:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
8010355e:	00 
8010355f:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103566:	e8 8f ff ff ff       	call   801034fa <lapicw>
  lapicw(TICR, 10000000); 
8010356b:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103572:	00 
80103573:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
8010357a:	e8 7b ff ff ff       	call   801034fa <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010357f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103586:	00 
80103587:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
8010358e:	e8 67 ff ff ff       	call   801034fa <lapicw>
  lapicw(LINT1, MASKED);
80103593:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010359a:	00 
8010359b:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801035a2:	e8 53 ff ff ff       	call   801034fa <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801035a7:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
801035ac:	83 c0 30             	add    $0x30,%eax
801035af:	8b 00                	mov    (%eax),%eax
801035b1:	c1 e8 10             	shr    $0x10,%eax
801035b4:	0f b6 c0             	movzbl %al,%eax
801035b7:	83 f8 03             	cmp    $0x3,%eax
801035ba:	76 14                	jbe    801035d0 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
801035bc:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801035c3:	00 
801035c4:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801035cb:	e8 2a ff ff ff       	call   801034fa <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801035d0:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801035d7:	00 
801035d8:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801035df:	e8 16 ff ff ff       	call   801034fa <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801035e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801035eb:	00 
801035ec:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801035f3:	e8 02 ff ff ff       	call   801034fa <lapicw>
  lapicw(ESR, 0);
801035f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801035ff:	00 
80103600:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103607:	e8 ee fe ff ff       	call   801034fa <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010360c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103613:	00 
80103614:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010361b:	e8 da fe ff ff       	call   801034fa <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103620:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103627:	00 
80103628:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010362f:	e8 c6 fe ff ff       	call   801034fa <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103634:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
8010363b:	00 
8010363c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103643:	e8 b2 fe ff ff       	call   801034fa <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103648:	90                   	nop
80103649:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
8010364e:	05 00 03 00 00       	add    $0x300,%eax
80103653:	8b 00                	mov    (%eax),%eax
80103655:	25 00 10 00 00       	and    $0x1000,%eax
8010365a:	85 c0                	test   %eax,%eax
8010365c:	75 eb                	jne    80103649 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010365e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103665:	00 
80103666:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010366d:	e8 88 fe ff ff       	call   801034fa <lapicw>
}
80103672:	c9                   	leave  
80103673:	c3                   	ret    

80103674 <cpunum>:

int
cpunum(void)
{
80103674:	55                   	push   %ebp
80103675:	89 e5                	mov    %esp,%ebp
80103677:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
8010367a:	e8 6b fe ff ff       	call   801034ea <readeflags>
8010367f:	25 00 02 00 00       	and    $0x200,%eax
80103684:	85 c0                	test   %eax,%eax
80103686:	74 25                	je     801036ad <cpunum+0x39>
    static int n;
    if(n++ == 0)
80103688:	a1 40 c6 10 80       	mov    0x8010c640,%eax
8010368d:	8d 50 01             	lea    0x1(%eax),%edx
80103690:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
80103696:	85 c0                	test   %eax,%eax
80103698:	75 13                	jne    801036ad <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
8010369a:	8b 45 04             	mov    0x4(%ebp),%eax
8010369d:	89 44 24 04          	mov    %eax,0x4(%esp)
801036a1:	c7 04 24 30 91 10 80 	movl   $0x80109130,(%esp)
801036a8:	e8 f3 cc ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801036ad:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
801036b2:	85 c0                	test   %eax,%eax
801036b4:	74 0f                	je     801036c5 <cpunum+0x51>
    return lapic[ID]>>24;
801036b6:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
801036bb:	83 c0 20             	add    $0x20,%eax
801036be:	8b 00                	mov    (%eax),%eax
801036c0:	c1 e8 18             	shr    $0x18,%eax
801036c3:	eb 05                	jmp    801036ca <cpunum+0x56>
  return 0;
801036c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801036ca:	c9                   	leave  
801036cb:	c3                   	ret    

801036cc <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801036cc:	55                   	push   %ebp
801036cd:	89 e5                	mov    %esp,%ebp
801036cf:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801036d2:	a1 7c 3a 11 80       	mov    0x80113a7c,%eax
801036d7:	85 c0                	test   %eax,%eax
801036d9:	74 14                	je     801036ef <lapiceoi+0x23>
    lapicw(EOI, 0);
801036db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801036e2:	00 
801036e3:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801036ea:	e8 0b fe ff ff       	call   801034fa <lapicw>
}
801036ef:	c9                   	leave  
801036f0:	c3                   	ret    

801036f1 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801036f1:	55                   	push   %ebp
801036f2:	89 e5                	mov    %esp,%ebp
}
801036f4:	5d                   	pop    %ebp
801036f5:	c3                   	ret    

801036f6 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801036f6:	55                   	push   %ebp
801036f7:	89 e5                	mov    %esp,%ebp
801036f9:	83 ec 1c             	sub    $0x1c,%esp
801036fc:	8b 45 08             	mov    0x8(%ebp),%eax
801036ff:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103702:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103709:	00 
8010370a:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103711:	e8 b6 fd ff ff       	call   801034cc <outb>
  outb(CMOS_PORT+1, 0x0A);
80103716:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010371d:	00 
8010371e:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103725:	e8 a2 fd ff ff       	call   801034cc <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010372a:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103731:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103734:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103739:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010373c:	8d 50 02             	lea    0x2(%eax),%edx
8010373f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103742:	c1 e8 04             	shr    $0x4,%eax
80103745:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103748:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010374c:	c1 e0 18             	shl    $0x18,%eax
8010374f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103753:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010375a:	e8 9b fd ff ff       	call   801034fa <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010375f:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103766:	00 
80103767:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010376e:	e8 87 fd ff ff       	call   801034fa <lapicw>
  microdelay(200);
80103773:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010377a:	e8 72 ff ff ff       	call   801036f1 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010377f:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103786:	00 
80103787:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010378e:	e8 67 fd ff ff       	call   801034fa <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103793:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010379a:	e8 52 ff ff ff       	call   801036f1 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010379f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801037a6:	eb 40                	jmp    801037e8 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801037a8:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801037ac:	c1 e0 18             	shl    $0x18,%eax
801037af:	89 44 24 04          	mov    %eax,0x4(%esp)
801037b3:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801037ba:	e8 3b fd ff ff       	call   801034fa <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801037bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801037c2:	c1 e8 0c             	shr    $0xc,%eax
801037c5:	80 cc 06             	or     $0x6,%ah
801037c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801037cc:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801037d3:	e8 22 fd ff ff       	call   801034fa <lapicw>
    microdelay(200);
801037d8:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801037df:	e8 0d ff ff ff       	call   801036f1 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801037e4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801037e8:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801037ec:	7e ba                	jle    801037a8 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801037ee:	c9                   	leave  
801037ef:	c3                   	ret    

801037f0 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801037f0:	55                   	push   %ebp
801037f1:	89 e5                	mov    %esp,%ebp
801037f3:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801037f6:	8b 45 08             	mov    0x8(%ebp),%eax
801037f9:	0f b6 c0             	movzbl %al,%eax
801037fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80103800:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103807:	e8 c0 fc ff ff       	call   801034cc <outb>
  microdelay(200);
8010380c:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103813:	e8 d9 fe ff ff       	call   801036f1 <microdelay>

  return inb(CMOS_RETURN);
80103818:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010381f:	e8 8b fc ff ff       	call   801034af <inb>
80103824:	0f b6 c0             	movzbl %al,%eax
}
80103827:	c9                   	leave  
80103828:	c3                   	ret    

80103829 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103829:	55                   	push   %ebp
8010382a:	89 e5                	mov    %esp,%ebp
8010382c:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
8010382f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103836:	e8 b5 ff ff ff       	call   801037f0 <cmos_read>
8010383b:	8b 55 08             	mov    0x8(%ebp),%edx
8010383e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103840:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103847:	e8 a4 ff ff ff       	call   801037f0 <cmos_read>
8010384c:	8b 55 08             	mov    0x8(%ebp),%edx
8010384f:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103852:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103859:	e8 92 ff ff ff       	call   801037f0 <cmos_read>
8010385e:	8b 55 08             	mov    0x8(%ebp),%edx
80103861:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103864:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010386b:	e8 80 ff ff ff       	call   801037f0 <cmos_read>
80103870:	8b 55 08             	mov    0x8(%ebp),%edx
80103873:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103876:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010387d:	e8 6e ff ff ff       	call   801037f0 <cmos_read>
80103882:	8b 55 08             	mov    0x8(%ebp),%edx
80103885:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103888:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
8010388f:	e8 5c ff ff ff       	call   801037f0 <cmos_read>
80103894:	8b 55 08             	mov    0x8(%ebp),%edx
80103897:	89 42 14             	mov    %eax,0x14(%edx)
}
8010389a:	c9                   	leave  
8010389b:	c3                   	ret    

8010389c <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010389c:	55                   	push   %ebp
8010389d:	89 e5                	mov    %esp,%ebp
8010389f:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801038a2:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801038a9:	e8 42 ff ff ff       	call   801037f0 <cmos_read>
801038ae:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801038b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038b4:	83 e0 04             	and    $0x4,%eax
801038b7:	85 c0                	test   %eax,%eax
801038b9:	0f 94 c0             	sete   %al
801038bc:	0f b6 c0             	movzbl %al,%eax
801038bf:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801038c2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801038c5:	89 04 24             	mov    %eax,(%esp)
801038c8:	e8 5c ff ff ff       	call   80103829 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801038cd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801038d4:	e8 17 ff ff ff       	call   801037f0 <cmos_read>
801038d9:	25 80 00 00 00       	and    $0x80,%eax
801038de:	85 c0                	test   %eax,%eax
801038e0:	74 02                	je     801038e4 <cmostime+0x48>
        continue;
801038e2:	eb 36                	jmp    8010391a <cmostime+0x7e>
    fill_rtcdate(&t2);
801038e4:	8d 45 c0             	lea    -0x40(%ebp),%eax
801038e7:	89 04 24             	mov    %eax,(%esp)
801038ea:	e8 3a ff ff ff       	call   80103829 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801038ef:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801038f6:	00 
801038f7:	8d 45 c0             	lea    -0x40(%ebp),%eax
801038fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801038fe:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103901:	89 04 24             	mov    %eax,(%esp)
80103904:	e8 9c 21 00 00       	call   80105aa5 <memcmp>
80103909:	85 c0                	test   %eax,%eax
8010390b:	75 0d                	jne    8010391a <cmostime+0x7e>
      break;
8010390d:	90                   	nop
  }

  // convert
  if (bcd) {
8010390e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103912:	0f 84 ac 00 00 00    	je     801039c4 <cmostime+0x128>
80103918:	eb 02                	jmp    8010391c <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010391a:	eb a6                	jmp    801038c2 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010391c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010391f:	c1 e8 04             	shr    $0x4,%eax
80103922:	89 c2                	mov    %eax,%edx
80103924:	89 d0                	mov    %edx,%eax
80103926:	c1 e0 02             	shl    $0x2,%eax
80103929:	01 d0                	add    %edx,%eax
8010392b:	01 c0                	add    %eax,%eax
8010392d:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103930:	83 e2 0f             	and    $0xf,%edx
80103933:	01 d0                	add    %edx,%eax
80103935:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103938:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010393b:	c1 e8 04             	shr    $0x4,%eax
8010393e:	89 c2                	mov    %eax,%edx
80103940:	89 d0                	mov    %edx,%eax
80103942:	c1 e0 02             	shl    $0x2,%eax
80103945:	01 d0                	add    %edx,%eax
80103947:	01 c0                	add    %eax,%eax
80103949:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010394c:	83 e2 0f             	and    $0xf,%edx
8010394f:	01 d0                	add    %edx,%eax
80103951:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103954:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103957:	c1 e8 04             	shr    $0x4,%eax
8010395a:	89 c2                	mov    %eax,%edx
8010395c:	89 d0                	mov    %edx,%eax
8010395e:	c1 e0 02             	shl    $0x2,%eax
80103961:	01 d0                	add    %edx,%eax
80103963:	01 c0                	add    %eax,%eax
80103965:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103968:	83 e2 0f             	and    $0xf,%edx
8010396b:	01 d0                	add    %edx,%eax
8010396d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103970:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103973:	c1 e8 04             	shr    $0x4,%eax
80103976:	89 c2                	mov    %eax,%edx
80103978:	89 d0                	mov    %edx,%eax
8010397a:	c1 e0 02             	shl    $0x2,%eax
8010397d:	01 d0                	add    %edx,%eax
8010397f:	01 c0                	add    %eax,%eax
80103981:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103984:	83 e2 0f             	and    $0xf,%edx
80103987:	01 d0                	add    %edx,%eax
80103989:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010398c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010398f:	c1 e8 04             	shr    $0x4,%eax
80103992:	89 c2                	mov    %eax,%edx
80103994:	89 d0                	mov    %edx,%eax
80103996:	c1 e0 02             	shl    $0x2,%eax
80103999:	01 d0                	add    %edx,%eax
8010399b:	01 c0                	add    %eax,%eax
8010399d:	8b 55 e8             	mov    -0x18(%ebp),%edx
801039a0:	83 e2 0f             	and    $0xf,%edx
801039a3:	01 d0                	add    %edx,%eax
801039a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801039a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039ab:	c1 e8 04             	shr    $0x4,%eax
801039ae:	89 c2                	mov    %eax,%edx
801039b0:	89 d0                	mov    %edx,%eax
801039b2:	c1 e0 02             	shl    $0x2,%eax
801039b5:	01 d0                	add    %edx,%eax
801039b7:	01 c0                	add    %eax,%eax
801039b9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801039bc:	83 e2 0f             	and    $0xf,%edx
801039bf:	01 d0                	add    %edx,%eax
801039c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801039c4:	8b 45 08             	mov    0x8(%ebp),%eax
801039c7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801039ca:	89 10                	mov    %edx,(%eax)
801039cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
801039cf:	89 50 04             	mov    %edx,0x4(%eax)
801039d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801039d5:	89 50 08             	mov    %edx,0x8(%eax)
801039d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801039db:	89 50 0c             	mov    %edx,0xc(%eax)
801039de:	8b 55 e8             	mov    -0x18(%ebp),%edx
801039e1:	89 50 10             	mov    %edx,0x10(%eax)
801039e4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801039e7:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801039ea:	8b 45 08             	mov    0x8(%ebp),%eax
801039ed:	8b 40 14             	mov    0x14(%eax),%eax
801039f0:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801039f6:	8b 45 08             	mov    0x8(%ebp),%eax
801039f9:	89 50 14             	mov    %edx,0x14(%eax)
}
801039fc:	c9                   	leave  
801039fd:	c3                   	ret    

801039fe <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801039fe:	55                   	push   %ebp
801039ff:	89 e5                	mov    %esp,%ebp
80103a01:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103a04:	c7 44 24 04 5c 91 10 	movl   $0x8010915c,0x4(%esp)
80103a0b:	80 
80103a0c:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103a13:	e8 a1 1d 00 00       	call   801057b9 <initlock>
  readsb(dev, &sb);
80103a18:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a22:	89 04 24             	mov    %eax,(%esp)
80103a25:	e8 28 e0 ff ff       	call   80101a52 <readsb>
  log.start = sb.logstart;
80103a2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a2d:	a3 b4 3a 11 80       	mov    %eax,0x80113ab4
  log.size = sb.nlog;
80103a32:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103a35:	a3 b8 3a 11 80       	mov    %eax,0x80113ab8
  log.dev = dev;
80103a3a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a3d:	a3 c4 3a 11 80       	mov    %eax,0x80113ac4
  recover_from_log();
80103a42:	e8 9a 01 00 00       	call   80103be1 <recover_from_log>
}
80103a47:	c9                   	leave  
80103a48:	c3                   	ret    

80103a49 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103a49:	55                   	push   %ebp
80103a4a:	89 e5                	mov    %esp,%ebp
80103a4c:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a56:	e9 8c 00 00 00       	jmp    80103ae7 <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103a5b:	8b 15 b4 3a 11 80    	mov    0x80113ab4,%edx
80103a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a64:	01 d0                	add    %edx,%eax
80103a66:	83 c0 01             	add    $0x1,%eax
80103a69:	89 c2                	mov    %eax,%edx
80103a6b:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103a70:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a74:	89 04 24             	mov    %eax,(%esp)
80103a77:	e8 2a c7 ff ff       	call   801001a6 <bread>
80103a7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a82:	83 c0 10             	add    $0x10,%eax
80103a85:	8b 04 85 8c 3a 11 80 	mov    -0x7feec574(,%eax,4),%eax
80103a8c:	89 c2                	mov    %eax,%edx
80103a8e:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103a93:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a97:	89 04 24             	mov    %eax,(%esp)
80103a9a:	e8 07 c7 ff ff       	call   801001a6 <bread>
80103a9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aa5:	8d 50 18             	lea    0x18(%eax),%edx
80103aa8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103aab:	83 c0 18             	add    $0x18,%eax
80103aae:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103ab5:	00 
80103ab6:	89 54 24 04          	mov    %edx,0x4(%esp)
80103aba:	89 04 24             	mov    %eax,(%esp)
80103abd:	e8 3b 20 00 00       	call   80105afd <memmove>
    bwrite(dbuf);  // write dst to disk
80103ac2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ac5:	89 04 24             	mov    %eax,(%esp)
80103ac8:	e8 10 c7 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad0:	89 04 24             	mov    %eax,(%esp)
80103ad3:	e8 3f c7 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103ad8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103adb:	89 04 24             	mov    %eax,(%esp)
80103ade:	e8 34 c7 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103ae3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ae7:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103aec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103aef:	0f 8f 66 ff ff ff    	jg     80103a5b <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103af5:	c9                   	leave  
80103af6:	c3                   	ret    

80103af7 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103af7:	55                   	push   %ebp
80103af8:	89 e5                	mov    %esp,%ebp
80103afa:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103afd:	a1 b4 3a 11 80       	mov    0x80113ab4,%eax
80103b02:	89 c2                	mov    %eax,%edx
80103b04:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103b09:	89 54 24 04          	mov    %edx,0x4(%esp)
80103b0d:	89 04 24             	mov    %eax,(%esp)
80103b10:	e8 91 c6 ff ff       	call   801001a6 <bread>
80103b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b1b:	83 c0 18             	add    $0x18,%eax
80103b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103b21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b24:	8b 00                	mov    (%eax),%eax
80103b26:	a3 c8 3a 11 80       	mov    %eax,0x80113ac8
  for (i = 0; i < log.lh.n; i++) {
80103b2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b32:	eb 1b                	jmp    80103b4f <read_head+0x58>
    log.lh.block[i] = lh->block[i];
80103b34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b3a:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103b3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b41:	83 c2 10             	add    $0x10,%edx
80103b44:	89 04 95 8c 3a 11 80 	mov    %eax,-0x7feec574(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103b4b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b4f:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103b54:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b57:	7f db                	jg     80103b34 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b5c:	89 04 24             	mov    %eax,(%esp)
80103b5f:	e8 b3 c6 ff ff       	call   80100217 <brelse>
}
80103b64:	c9                   	leave  
80103b65:	c3                   	ret    

80103b66 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103b66:	55                   	push   %ebp
80103b67:	89 e5                	mov    %esp,%ebp
80103b69:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103b6c:	a1 b4 3a 11 80       	mov    0x80113ab4,%eax
80103b71:	89 c2                	mov    %eax,%edx
80103b73:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103b78:	89 54 24 04          	mov    %edx,0x4(%esp)
80103b7c:	89 04 24             	mov    %eax,(%esp)
80103b7f:	e8 22 c6 ff ff       	call   801001a6 <bread>
80103b84:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b8a:	83 c0 18             	add    $0x18,%eax
80103b8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103b90:	8b 15 c8 3a 11 80    	mov    0x80113ac8,%edx
80103b96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b99:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103b9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ba2:	eb 1b                	jmp    80103bbf <write_head+0x59>
    hb->block[i] = log.lh.block[i];
80103ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba7:	83 c0 10             	add    $0x10,%eax
80103baa:	8b 0c 85 8c 3a 11 80 	mov    -0x7feec574(,%eax,4),%ecx
80103bb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bb7:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103bbb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bbf:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103bc4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103bc7:	7f db                	jg     80103ba4 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcc:	89 04 24             	mov    %eax,(%esp)
80103bcf:	e8 09 c6 ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd7:	89 04 24             	mov    %eax,(%esp)
80103bda:	e8 38 c6 ff ff       	call   80100217 <brelse>
}
80103bdf:	c9                   	leave  
80103be0:	c3                   	ret    

80103be1 <recover_from_log>:

static void
recover_from_log(void)
{
80103be1:	55                   	push   %ebp
80103be2:	89 e5                	mov    %esp,%ebp
80103be4:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103be7:	e8 0b ff ff ff       	call   80103af7 <read_head>
  install_trans(); // if committed, copy from log to disk
80103bec:	e8 58 fe ff ff       	call   80103a49 <install_trans>
  log.lh.n = 0;
80103bf1:	c7 05 c8 3a 11 80 00 	movl   $0x0,0x80113ac8
80103bf8:	00 00 00 
  write_head(); // clear the log
80103bfb:	e8 66 ff ff ff       	call   80103b66 <write_head>
}
80103c00:	c9                   	leave  
80103c01:	c3                   	ret    

80103c02 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103c02:	55                   	push   %ebp
80103c03:	89 e5                	mov    %esp,%ebp
80103c05:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103c08:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103c0f:	e8 c6 1b 00 00       	call   801057da <acquire>
  while(1){
    if(log.committing){
80103c14:	a1 c0 3a 11 80       	mov    0x80113ac0,%eax
80103c19:	85 c0                	test   %eax,%eax
80103c1b:	74 16                	je     80103c33 <begin_op+0x31>
      sleep(&log, &log.lock);
80103c1d:	c7 44 24 04 80 3a 11 	movl   $0x80113a80,0x4(%esp)
80103c24:	80 
80103c25:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103c2c:	e8 5a 18 00 00       	call   8010548b <sleep>
80103c31:	eb 4f                	jmp    80103c82 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103c33:	8b 0d c8 3a 11 80    	mov    0x80113ac8,%ecx
80103c39:	a1 bc 3a 11 80       	mov    0x80113abc,%eax
80103c3e:	8d 50 01             	lea    0x1(%eax),%edx
80103c41:	89 d0                	mov    %edx,%eax
80103c43:	c1 e0 02             	shl    $0x2,%eax
80103c46:	01 d0                	add    %edx,%eax
80103c48:	01 c0                	add    %eax,%eax
80103c4a:	01 c8                	add    %ecx,%eax
80103c4c:	83 f8 1e             	cmp    $0x1e,%eax
80103c4f:	7e 16                	jle    80103c67 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103c51:	c7 44 24 04 80 3a 11 	movl   $0x80113a80,0x4(%esp)
80103c58:	80 
80103c59:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103c60:	e8 26 18 00 00       	call   8010548b <sleep>
80103c65:	eb 1b                	jmp    80103c82 <begin_op+0x80>
    } else {
      log.outstanding += 1;
80103c67:	a1 bc 3a 11 80       	mov    0x80113abc,%eax
80103c6c:	83 c0 01             	add    $0x1,%eax
80103c6f:	a3 bc 3a 11 80       	mov    %eax,0x80113abc
      release(&log.lock);
80103c74:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103c7b:	e8 bc 1b 00 00       	call   8010583c <release>
      break;
80103c80:	eb 02                	jmp    80103c84 <begin_op+0x82>
    }
  }
80103c82:	eb 90                	jmp    80103c14 <begin_op+0x12>
}
80103c84:	c9                   	leave  
80103c85:	c3                   	ret    

80103c86 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103c86:	55                   	push   %ebp
80103c87:	89 e5                	mov    %esp,%ebp
80103c89:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103c8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103c93:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103c9a:	e8 3b 1b 00 00       	call   801057da <acquire>
  log.outstanding -= 1;
80103c9f:	a1 bc 3a 11 80       	mov    0x80113abc,%eax
80103ca4:	83 e8 01             	sub    $0x1,%eax
80103ca7:	a3 bc 3a 11 80       	mov    %eax,0x80113abc
  if(log.committing)
80103cac:	a1 c0 3a 11 80       	mov    0x80113ac0,%eax
80103cb1:	85 c0                	test   %eax,%eax
80103cb3:	74 0c                	je     80103cc1 <end_op+0x3b>
    panic("log.committing");
80103cb5:	c7 04 24 60 91 10 80 	movl   $0x80109160,(%esp)
80103cbc:	e8 79 c8 ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
80103cc1:	a1 bc 3a 11 80       	mov    0x80113abc,%eax
80103cc6:	85 c0                	test   %eax,%eax
80103cc8:	75 13                	jne    80103cdd <end_op+0x57>
    do_commit = 1;
80103cca:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103cd1:	c7 05 c0 3a 11 80 01 	movl   $0x1,0x80113ac0
80103cd8:	00 00 00 
80103cdb:	eb 0c                	jmp    80103ce9 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103cdd:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103ce4:	e8 7e 18 00 00       	call   80105567 <wakeup>
  }
  release(&log.lock);
80103ce9:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103cf0:	e8 47 1b 00 00       	call   8010583c <release>

  if(do_commit){
80103cf5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cf9:	74 33                	je     80103d2e <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103cfb:	e8 de 00 00 00       	call   80103dde <commit>
    acquire(&log.lock);
80103d00:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103d07:	e8 ce 1a 00 00       	call   801057da <acquire>
    log.committing = 0;
80103d0c:	c7 05 c0 3a 11 80 00 	movl   $0x0,0x80113ac0
80103d13:	00 00 00 
    wakeup(&log);
80103d16:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103d1d:	e8 45 18 00 00       	call   80105567 <wakeup>
    release(&log.lock);
80103d22:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103d29:	e8 0e 1b 00 00       	call   8010583c <release>
  }
}
80103d2e:	c9                   	leave  
80103d2f:	c3                   	ret    

80103d30 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103d30:	55                   	push   %ebp
80103d31:	89 e5                	mov    %esp,%ebp
80103d33:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103d36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d3d:	e9 8c 00 00 00       	jmp    80103dce <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103d42:	8b 15 b4 3a 11 80    	mov    0x80113ab4,%edx
80103d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4b:	01 d0                	add    %edx,%eax
80103d4d:	83 c0 01             	add    $0x1,%eax
80103d50:	89 c2                	mov    %eax,%edx
80103d52:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103d57:	89 54 24 04          	mov    %edx,0x4(%esp)
80103d5b:	89 04 24             	mov    %eax,(%esp)
80103d5e:	e8 43 c4 ff ff       	call   801001a6 <bread>
80103d63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d69:	83 c0 10             	add    $0x10,%eax
80103d6c:	8b 04 85 8c 3a 11 80 	mov    -0x7feec574(,%eax,4),%eax
80103d73:	89 c2                	mov    %eax,%edx
80103d75:	a1 c4 3a 11 80       	mov    0x80113ac4,%eax
80103d7a:	89 54 24 04          	mov    %edx,0x4(%esp)
80103d7e:	89 04 24             	mov    %eax,(%esp)
80103d81:	e8 20 c4 ff ff       	call   801001a6 <bread>
80103d86:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103d89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d8c:	8d 50 18             	lea    0x18(%eax),%edx
80103d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d92:	83 c0 18             	add    $0x18,%eax
80103d95:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103d9c:	00 
80103d9d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103da1:	89 04 24             	mov    %eax,(%esp)
80103da4:	e8 54 1d 00 00       	call   80105afd <memmove>
    bwrite(to);  // write the log
80103da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dac:	89 04 24             	mov    %eax,(%esp)
80103daf:	e8 29 c4 ff ff       	call   801001dd <bwrite>
    brelse(from); 
80103db4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103db7:	89 04 24             	mov    %eax,(%esp)
80103dba:	e8 58 c4 ff ff       	call   80100217 <brelse>
    brelse(to);
80103dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dc2:	89 04 24             	mov    %eax,(%esp)
80103dc5:	e8 4d c4 ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103dca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103dce:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103dd3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103dd6:	0f 8f 66 ff ff ff    	jg     80103d42 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103ddc:	c9                   	leave  
80103ddd:	c3                   	ret    

80103dde <commit>:

static void
commit()
{
80103dde:	55                   	push   %ebp
80103ddf:	89 e5                	mov    %esp,%ebp
80103de1:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103de4:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103de9:	85 c0                	test   %eax,%eax
80103deb:	7e 1e                	jle    80103e0b <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103ded:	e8 3e ff ff ff       	call   80103d30 <write_log>
    write_head();    // Write header to disk -- the real commit
80103df2:	e8 6f fd ff ff       	call   80103b66 <write_head>
    install_trans(); // Now install writes to home locations
80103df7:	e8 4d fc ff ff       	call   80103a49 <install_trans>
    log.lh.n = 0; 
80103dfc:	c7 05 c8 3a 11 80 00 	movl   $0x0,0x80113ac8
80103e03:	00 00 00 
    write_head();    // Erase the transaction from the log
80103e06:	e8 5b fd ff ff       	call   80103b66 <write_head>
  }
}
80103e0b:	c9                   	leave  
80103e0c:	c3                   	ret    

80103e0d <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103e0d:	55                   	push   %ebp
80103e0e:	89 e5                	mov    %esp,%ebp
80103e10:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103e13:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103e18:	83 f8 1d             	cmp    $0x1d,%eax
80103e1b:	7f 12                	jg     80103e2f <log_write+0x22>
80103e1d:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103e22:	8b 15 b8 3a 11 80    	mov    0x80113ab8,%edx
80103e28:	83 ea 01             	sub    $0x1,%edx
80103e2b:	39 d0                	cmp    %edx,%eax
80103e2d:	7c 0c                	jl     80103e3b <log_write+0x2e>
    panic("too big a transaction");
80103e2f:	c7 04 24 6f 91 10 80 	movl   $0x8010916f,(%esp)
80103e36:	e8 ff c6 ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103e3b:	a1 bc 3a 11 80       	mov    0x80113abc,%eax
80103e40:	85 c0                	test   %eax,%eax
80103e42:	7f 0c                	jg     80103e50 <log_write+0x43>
    panic("log_write outside of trans");
80103e44:	c7 04 24 85 91 10 80 	movl   $0x80109185,(%esp)
80103e4b:	e8 ea c6 ff ff       	call   8010053a <panic>

  acquire(&log.lock);
80103e50:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103e57:	e8 7e 19 00 00       	call   801057da <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103e5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e63:	eb 1f                	jmp    80103e84 <log_write+0x77>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e68:	83 c0 10             	add    $0x10,%eax
80103e6b:	8b 04 85 8c 3a 11 80 	mov    -0x7feec574(,%eax,4),%eax
80103e72:	89 c2                	mov    %eax,%edx
80103e74:	8b 45 08             	mov    0x8(%ebp),%eax
80103e77:	8b 40 08             	mov    0x8(%eax),%eax
80103e7a:	39 c2                	cmp    %eax,%edx
80103e7c:	75 02                	jne    80103e80 <log_write+0x73>
      break;
80103e7e:	eb 0e                	jmp    80103e8e <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103e80:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e84:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103e89:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e8c:	7f d7                	jg     80103e65 <log_write+0x58>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e91:	8b 40 08             	mov    0x8(%eax),%eax
80103e94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e97:	83 c2 10             	add    $0x10,%edx
80103e9a:	89 04 95 8c 3a 11 80 	mov    %eax,-0x7feec574(,%edx,4)
  if (i == log.lh.n)
80103ea1:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103ea6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ea9:	75 0d                	jne    80103eb8 <log_write+0xab>
    log.lh.n++;
80103eab:	a1 c8 3a 11 80       	mov    0x80113ac8,%eax
80103eb0:	83 c0 01             	add    $0x1,%eax
80103eb3:	a3 c8 3a 11 80       	mov    %eax,0x80113ac8
  b->flags |= B_DIRTY; // prevent eviction
80103eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ebb:	8b 00                	mov    (%eax),%eax
80103ebd:	83 c8 04             	or     $0x4,%eax
80103ec0:	89 c2                	mov    %eax,%edx
80103ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec5:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103ec7:	c7 04 24 80 3a 11 80 	movl   $0x80113a80,(%esp)
80103ece:	e8 69 19 00 00       	call   8010583c <release>
}
80103ed3:	c9                   	leave  
80103ed4:	c3                   	ret    

80103ed5 <v2p>:
80103ed5:	55                   	push   %ebp
80103ed6:	89 e5                	mov    %esp,%ebp
80103ed8:	8b 45 08             	mov    0x8(%ebp),%eax
80103edb:	05 00 00 00 80       	add    $0x80000000,%eax
80103ee0:	5d                   	pop    %ebp
80103ee1:	c3                   	ret    

80103ee2 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103ee2:	55                   	push   %ebp
80103ee3:	89 e5                	mov    %esp,%ebp
80103ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee8:	05 00 00 00 80       	add    $0x80000000,%eax
80103eed:	5d                   	pop    %ebp
80103eee:	c3                   	ret    

80103eef <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103eef:	55                   	push   %ebp
80103ef0:	89 e5                	mov    %esp,%ebp
80103ef2:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103ef5:	8b 55 08             	mov    0x8(%ebp),%edx
80103ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103efb:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103efe:	f0 87 02             	lock xchg %eax,(%edx)
80103f01:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103f04:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103f07:	c9                   	leave  
80103f08:	c3                   	ret    

80103f09 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103f09:	55                   	push   %ebp
80103f0a:	89 e5                	mov    %esp,%ebp
80103f0c:	83 e4 f0             	and    $0xfffffff0,%esp
80103f0f:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103f12:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103f19:	80 
80103f1a:	c7 04 24 5c 6d 11 80 	movl   $0x80116d5c,(%esp)
80103f21:	e8 8a f2 ff ff       	call   801031b0 <kinit1>
  kvmalloc();      // kernel page table
80103f26:	e8 03 48 00 00       	call   8010872e <kvmalloc>
  mpinit();        // collect info about this machine
80103f2b:	e8 41 04 00 00       	call   80104371 <mpinit>
  lapicinit();
80103f30:	e8 e6 f5 ff ff       	call   8010351b <lapicinit>
  seginit();       // set up segments
80103f35:	e8 87 41 00 00       	call   801080c1 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103f3a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103f40:	0f b6 00             	movzbl (%eax),%eax
80103f43:	0f b6 c0             	movzbl %al,%eax
80103f46:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f4a:	c7 04 24 a0 91 10 80 	movl   $0x801091a0,(%esp)
80103f51:	e8 4a c4 ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103f56:	e8 74 06 00 00       	call   801045cf <picinit>
  ioapicinit();    // another interrupt controller
80103f5b:	e8 46 f1 ff ff       	call   801030a6 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103f60:	e8 7d d2 ff ff       	call   801011e2 <consoleinit>
  uartinit();      // serial port
80103f65:	e8 a6 34 00 00       	call   80107410 <uartinit>
  pinit();         // process table
80103f6a:	e8 6a 0b 00 00       	call   80104ad9 <pinit>
  tvinit();        // trap vectors
80103f6f:	e8 49 30 00 00       	call   80106fbd <tvinit>
  binit();         // buffer cache
80103f74:	e8 bb c0 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103f79:	e8 ed d6 ff ff       	call   8010166b <fileinit>
  ideinit();       // disk
80103f7e:	e8 55 ed ff ff       	call   80102cd8 <ideinit>
  if(!ismp)
80103f83:	a1 64 3b 11 80       	mov    0x80113b64,%eax
80103f88:	85 c0                	test   %eax,%eax
80103f8a:	75 05                	jne    80103f91 <main+0x88>
    timerinit();   // uniprocessor timer
80103f8c:	e8 77 2f 00 00       	call   80106f08 <timerinit>
  startothers();   // start other processors
80103f91:	e8 7f 00 00 00       	call   80104015 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103f96:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103f9d:	8e 
80103f9e:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103fa5:	e8 3e f2 ff ff       	call   801031e8 <kinit2>
  userinit();      // first user process
80103faa:	e8 48 0c 00 00       	call   80104bf7 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103faf:	e8 1a 00 00 00       	call   80103fce <mpmain>

80103fb4 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103fb4:	55                   	push   %ebp
80103fb5:	89 e5                	mov    %esp,%ebp
80103fb7:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103fba:	e8 86 47 00 00       	call   80108745 <switchkvm>
  seginit();
80103fbf:	e8 fd 40 00 00       	call   801080c1 <seginit>
  lapicinit();
80103fc4:	e8 52 f5 ff ff       	call   8010351b <lapicinit>
  mpmain();
80103fc9:	e8 00 00 00 00       	call   80103fce <mpmain>

80103fce <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103fce:	55                   	push   %ebp
80103fcf:	89 e5                	mov    %esp,%ebp
80103fd1:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103fd4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103fda:	0f b6 00             	movzbl (%eax),%eax
80103fdd:	0f b6 c0             	movzbl %al,%eax
80103fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
80103fe4:	c7 04 24 b7 91 10 80 	movl   $0x801091b7,(%esp)
80103feb:	e8 b0 c3 ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103ff0:	e8 3c 31 00 00       	call   80107131 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103ff5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103ffb:	05 a8 00 00 00       	add    $0xa8,%eax
80104000:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104007:	00 
80104008:	89 04 24             	mov    %eax,(%esp)
8010400b:	e8 df fe ff ff       	call   80103eef <xchg>
  scheduler();     // start running processes
80104010:	e8 b8 12 00 00       	call   801052cd <scheduler>

80104015 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80104015:	55                   	push   %ebp
80104016:	89 e5                	mov    %esp,%ebp
80104018:	53                   	push   %ebx
80104019:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010401c:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80104023:	e8 ba fe ff ff       	call   80103ee2 <p2v>
80104028:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010402b:	b8 8a 00 00 00       	mov    $0x8a,%eax
80104030:	89 44 24 08          	mov    %eax,0x8(%esp)
80104034:	c7 44 24 04 0c c5 10 	movl   $0x8010c50c,0x4(%esp)
8010403b:	80 
8010403c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010403f:	89 04 24             	mov    %eax,(%esp)
80104042:	e8 b6 1a 00 00       	call   80105afd <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80104047:	c7 45 f4 80 3b 11 80 	movl   $0x80113b80,-0xc(%ebp)
8010404e:	e9 85 00 00 00       	jmp    801040d8 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80104053:	e8 1c f6 ff ff       	call   80103674 <cpunum>
80104058:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010405e:	05 80 3b 11 80       	add    $0x80113b80,%eax
80104063:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104066:	75 02                	jne    8010406a <startothers+0x55>
      continue;
80104068:	eb 67                	jmp    801040d1 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010406a:	e8 6f f2 ff ff       	call   801032de <kalloc>
8010406f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80104072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104075:	83 e8 04             	sub    $0x4,%eax
80104078:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010407b:	81 c2 00 10 00 00    	add    $0x1000,%edx
80104081:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104083:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104086:	83 e8 08             	sub    $0x8,%eax
80104089:	c7 00 b4 3f 10 80    	movl   $0x80103fb4,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010408f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104092:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104095:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
8010409c:	e8 34 fe ff ff       	call   80103ed5 <v2p>
801040a1:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801040a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040a6:	89 04 24             	mov    %eax,(%esp)
801040a9:	e8 27 fe ff ff       	call   80103ed5 <v2p>
801040ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040b1:	0f b6 12             	movzbl (%edx),%edx
801040b4:	0f b6 d2             	movzbl %dl,%edx
801040b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801040bb:	89 14 24             	mov    %edx,(%esp)
801040be:	e8 33 f6 ff ff       	call   801036f6 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801040c3:	90                   	nop
801040c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c7:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801040cd:	85 c0                	test   %eax,%eax
801040cf:	74 f3                	je     801040c4 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801040d1:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801040d8:	a1 60 41 11 80       	mov    0x80114160,%eax
801040dd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801040e3:	05 80 3b 11 80       	add    $0x80113b80,%eax
801040e8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801040eb:	0f 87 62 ff ff ff    	ja     80104053 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801040f1:	83 c4 24             	add    $0x24,%esp
801040f4:	5b                   	pop    %ebx
801040f5:	5d                   	pop    %ebp
801040f6:	c3                   	ret    

801040f7 <p2v>:
801040f7:	55                   	push   %ebp
801040f8:	89 e5                	mov    %esp,%ebp
801040fa:	8b 45 08             	mov    0x8(%ebp),%eax
801040fd:	05 00 00 00 80       	add    $0x80000000,%eax
80104102:	5d                   	pop    %ebp
80104103:	c3                   	ret    

80104104 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80104104:	55                   	push   %ebp
80104105:	89 e5                	mov    %esp,%ebp
80104107:	83 ec 14             	sub    $0x14,%esp
8010410a:	8b 45 08             	mov    0x8(%ebp),%eax
8010410d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80104111:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80104115:	89 c2                	mov    %eax,%edx
80104117:	ec                   	in     (%dx),%al
80104118:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010411b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010411f:	c9                   	leave  
80104120:	c3                   	ret    

80104121 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104121:	55                   	push   %ebp
80104122:	89 e5                	mov    %esp,%ebp
80104124:	83 ec 08             	sub    $0x8,%esp
80104127:	8b 55 08             	mov    0x8(%ebp),%edx
8010412a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010412d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104131:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104134:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104138:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010413c:	ee                   	out    %al,(%dx)
}
8010413d:	c9                   	leave  
8010413e:	c3                   	ret    

8010413f <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
8010413f:	55                   	push   %ebp
80104140:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80104142:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80104147:	89 c2                	mov    %eax,%edx
80104149:	b8 80 3b 11 80       	mov    $0x80113b80,%eax
8010414e:	29 c2                	sub    %eax,%edx
80104150:	89 d0                	mov    %edx,%eax
80104152:	c1 f8 02             	sar    $0x2,%eax
80104155:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010415b:	5d                   	pop    %ebp
8010415c:	c3                   	ret    

8010415d <sum>:

static uchar
sum(uchar *addr, int len)
{
8010415d:	55                   	push   %ebp
8010415e:	89 e5                	mov    %esp,%ebp
80104160:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80104163:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010416a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104171:	eb 15                	jmp    80104188 <sum+0x2b>
    sum += addr[i];
80104173:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104176:	8b 45 08             	mov    0x8(%ebp),%eax
80104179:	01 d0                	add    %edx,%eax
8010417b:	0f b6 00             	movzbl (%eax),%eax
8010417e:	0f b6 c0             	movzbl %al,%eax
80104181:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80104184:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104188:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010418b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010418e:	7c e3                	jl     80104173 <sum+0x16>
    sum += addr[i];
  return sum;
80104190:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104193:	c9                   	leave  
80104194:	c3                   	ret    

80104195 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104195:	55                   	push   %ebp
80104196:	89 e5                	mov    %esp,%ebp
80104198:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
8010419b:	8b 45 08             	mov    0x8(%ebp),%eax
8010419e:	89 04 24             	mov    %eax,(%esp)
801041a1:	e8 51 ff ff ff       	call   801040f7 <p2v>
801041a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801041a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801041ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041af:	01 d0                	add    %edx,%eax
801041b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801041b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041ba:	eb 3f                	jmp    801041fb <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801041bc:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801041c3:	00 
801041c4:	c7 44 24 04 c8 91 10 	movl   $0x801091c8,0x4(%esp)
801041cb:	80 
801041cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041cf:	89 04 24             	mov    %eax,(%esp)
801041d2:	e8 ce 18 00 00       	call   80105aa5 <memcmp>
801041d7:	85 c0                	test   %eax,%eax
801041d9:	75 1c                	jne    801041f7 <mpsearch1+0x62>
801041db:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801041e2:	00 
801041e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e6:	89 04 24             	mov    %eax,(%esp)
801041e9:	e8 6f ff ff ff       	call   8010415d <sum>
801041ee:	84 c0                	test   %al,%al
801041f0:	75 05                	jne    801041f7 <mpsearch1+0x62>
      return (struct mp*)p;
801041f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f5:	eb 11                	jmp    80104208 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801041f7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801041fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104201:	72 b9                	jb     801041bc <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80104203:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104208:	c9                   	leave  
80104209:	c3                   	ret    

8010420a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
8010420a:	55                   	push   %ebp
8010420b:	89 e5                	mov    %esp,%ebp
8010420d:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80104210:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80104217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421a:	83 c0 0f             	add    $0xf,%eax
8010421d:	0f b6 00             	movzbl (%eax),%eax
80104220:	0f b6 c0             	movzbl %al,%eax
80104223:	c1 e0 08             	shl    $0x8,%eax
80104226:	89 c2                	mov    %eax,%edx
80104228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422b:	83 c0 0e             	add    $0xe,%eax
8010422e:	0f b6 00             	movzbl (%eax),%eax
80104231:	0f b6 c0             	movzbl %al,%eax
80104234:	09 d0                	or     %edx,%eax
80104236:	c1 e0 04             	shl    $0x4,%eax
80104239:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010423c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104240:	74 21                	je     80104263 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80104242:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80104249:	00 
8010424a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010424d:	89 04 24             	mov    %eax,(%esp)
80104250:	e8 40 ff ff ff       	call   80104195 <mpsearch1>
80104255:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104258:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010425c:	74 50                	je     801042ae <mpsearch+0xa4>
      return mp;
8010425e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104261:	eb 5f                	jmp    801042c2 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80104263:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104266:	83 c0 14             	add    $0x14,%eax
80104269:	0f b6 00             	movzbl (%eax),%eax
8010426c:	0f b6 c0             	movzbl %al,%eax
8010426f:	c1 e0 08             	shl    $0x8,%eax
80104272:	89 c2                	mov    %eax,%edx
80104274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104277:	83 c0 13             	add    $0x13,%eax
8010427a:	0f b6 00             	movzbl (%eax),%eax
8010427d:	0f b6 c0             	movzbl %al,%eax
80104280:	09 d0                	or     %edx,%eax
80104282:	c1 e0 0a             	shl    $0xa,%eax
80104285:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80104288:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010428b:	2d 00 04 00 00       	sub    $0x400,%eax
80104290:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80104297:	00 
80104298:	89 04 24             	mov    %eax,(%esp)
8010429b:	e8 f5 fe ff ff       	call   80104195 <mpsearch1>
801042a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801042a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801042a7:	74 05                	je     801042ae <mpsearch+0xa4>
      return mp;
801042a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042ac:	eb 14                	jmp    801042c2 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
801042ae:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801042b5:	00 
801042b6:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
801042bd:	e8 d3 fe ff ff       	call   80104195 <mpsearch1>
}
801042c2:	c9                   	leave  
801042c3:	c3                   	ret    

801042c4 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801042c4:	55                   	push   %ebp
801042c5:	89 e5                	mov    %esp,%ebp
801042c7:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801042ca:	e8 3b ff ff ff       	call   8010420a <mpsearch>
801042cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801042d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042d6:	74 0a                	je     801042e2 <mpconfig+0x1e>
801042d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042db:	8b 40 04             	mov    0x4(%eax),%eax
801042de:	85 c0                	test   %eax,%eax
801042e0:	75 0a                	jne    801042ec <mpconfig+0x28>
    return 0;
801042e2:	b8 00 00 00 00       	mov    $0x0,%eax
801042e7:	e9 83 00 00 00       	jmp    8010436f <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801042ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ef:	8b 40 04             	mov    0x4(%eax),%eax
801042f2:	89 04 24             	mov    %eax,(%esp)
801042f5:	e8 fd fd ff ff       	call   801040f7 <p2v>
801042fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801042fd:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80104304:	00 
80104305:	c7 44 24 04 cd 91 10 	movl   $0x801091cd,0x4(%esp)
8010430c:	80 
8010430d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104310:	89 04 24             	mov    %eax,(%esp)
80104313:	e8 8d 17 00 00       	call   80105aa5 <memcmp>
80104318:	85 c0                	test   %eax,%eax
8010431a:	74 07                	je     80104323 <mpconfig+0x5f>
    return 0;
8010431c:	b8 00 00 00 00       	mov    $0x0,%eax
80104321:	eb 4c                	jmp    8010436f <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80104323:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104326:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010432a:	3c 01                	cmp    $0x1,%al
8010432c:	74 12                	je     80104340 <mpconfig+0x7c>
8010432e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104331:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104335:	3c 04                	cmp    $0x4,%al
80104337:	74 07                	je     80104340 <mpconfig+0x7c>
    return 0;
80104339:	b8 00 00 00 00       	mov    $0x0,%eax
8010433e:	eb 2f                	jmp    8010436f <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80104340:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104343:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104347:	0f b7 c0             	movzwl %ax,%eax
8010434a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010434e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104351:	89 04 24             	mov    %eax,(%esp)
80104354:	e8 04 fe ff ff       	call   8010415d <sum>
80104359:	84 c0                	test   %al,%al
8010435b:	74 07                	je     80104364 <mpconfig+0xa0>
    return 0;
8010435d:	b8 00 00 00 00       	mov    $0x0,%eax
80104362:	eb 0b                	jmp    8010436f <mpconfig+0xab>
  *pmp = mp;
80104364:	8b 45 08             	mov    0x8(%ebp),%eax
80104367:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010436a:	89 10                	mov    %edx,(%eax)
  return conf;
8010436c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010436f:	c9                   	leave  
80104370:	c3                   	ret    

80104371 <mpinit>:

void
mpinit(void)
{
80104371:	55                   	push   %ebp
80104372:	89 e5                	mov    %esp,%ebp
80104374:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104377:	c7 05 44 c6 10 80 80 	movl   $0x80113b80,0x8010c644
8010437e:	3b 11 80 
  if((conf = mpconfig(&mp)) == 0)
80104381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104384:	89 04 24             	mov    %eax,(%esp)
80104387:	e8 38 ff ff ff       	call   801042c4 <mpconfig>
8010438c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010438f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104393:	75 05                	jne    8010439a <mpinit+0x29>
    return;
80104395:	e9 9c 01 00 00       	jmp    80104536 <mpinit+0x1c5>
  ismp = 1;
8010439a:	c7 05 64 3b 11 80 01 	movl   $0x1,0x80113b64
801043a1:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801043a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043a7:	8b 40 24             	mov    0x24(%eax),%eax
801043aa:	a3 7c 3a 11 80       	mov    %eax,0x80113a7c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801043af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043b2:	83 c0 2c             	add    $0x2c,%eax
801043b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801043b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043bb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801043bf:	0f b7 d0             	movzwl %ax,%edx
801043c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043c5:	01 d0                	add    %edx,%eax
801043c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801043ca:	e9 f4 00 00 00       	jmp    801044c3 <mpinit+0x152>
    switch(*p){
801043cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d2:	0f b6 00             	movzbl (%eax),%eax
801043d5:	0f b6 c0             	movzbl %al,%eax
801043d8:	83 f8 04             	cmp    $0x4,%eax
801043db:	0f 87 bf 00 00 00    	ja     801044a0 <mpinit+0x12f>
801043e1:	8b 04 85 10 92 10 80 	mov    -0x7fef6df0(,%eax,4),%eax
801043e8:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801043ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801043f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043f3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801043f7:	0f b6 d0             	movzbl %al,%edx
801043fa:	a1 60 41 11 80       	mov    0x80114160,%eax
801043ff:	39 c2                	cmp    %eax,%edx
80104401:	74 2d                	je     80104430 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104403:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104406:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010440a:	0f b6 d0             	movzbl %al,%edx
8010440d:	a1 60 41 11 80       	mov    0x80114160,%eax
80104412:	89 54 24 08          	mov    %edx,0x8(%esp)
80104416:	89 44 24 04          	mov    %eax,0x4(%esp)
8010441a:	c7 04 24 d2 91 10 80 	movl   $0x801091d2,(%esp)
80104421:	e8 7a bf ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80104426:	c7 05 64 3b 11 80 00 	movl   $0x0,0x80113b64
8010442d:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80104430:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104433:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104437:	0f b6 c0             	movzbl %al,%eax
8010443a:	83 e0 02             	and    $0x2,%eax
8010443d:	85 c0                	test   %eax,%eax
8010443f:	74 15                	je     80104456 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80104441:	a1 60 41 11 80       	mov    0x80114160,%eax
80104446:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010444c:	05 80 3b 11 80       	add    $0x80113b80,%eax
80104451:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80104456:	8b 15 60 41 11 80    	mov    0x80114160,%edx
8010445c:	a1 60 41 11 80       	mov    0x80114160,%eax
80104461:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80104467:	81 c2 80 3b 11 80    	add    $0x80113b80,%edx
8010446d:	88 02                	mov    %al,(%edx)
      ncpu++;
8010446f:	a1 60 41 11 80       	mov    0x80114160,%eax
80104474:	83 c0 01             	add    $0x1,%eax
80104477:	a3 60 41 11 80       	mov    %eax,0x80114160
      p += sizeof(struct mpproc);
8010447c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104480:	eb 41                	jmp    801044c3 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104488:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010448b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010448f:	a2 60 3b 11 80       	mov    %al,0x80113b60
      p += sizeof(struct mpioapic);
80104494:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104498:	eb 29                	jmp    801044c3 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010449a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010449e:	eb 23                	jmp    801044c3 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801044a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a3:	0f b6 00             	movzbl (%eax),%eax
801044a6:	0f b6 c0             	movzbl %al,%eax
801044a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801044ad:	c7 04 24 f0 91 10 80 	movl   $0x801091f0,(%esp)
801044b4:	e8 e7 be ff ff       	call   801003a0 <cprintf>
      ismp = 0;
801044b9:	c7 05 64 3b 11 80 00 	movl   $0x0,0x80113b64
801044c0:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801044c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801044c9:	0f 82 00 ff ff ff    	jb     801043cf <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801044cf:	a1 64 3b 11 80       	mov    0x80113b64,%eax
801044d4:	85 c0                	test   %eax,%eax
801044d6:	75 1d                	jne    801044f5 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801044d8:	c7 05 60 41 11 80 01 	movl   $0x1,0x80114160
801044df:	00 00 00 
    lapic = 0;
801044e2:	c7 05 7c 3a 11 80 00 	movl   $0x0,0x80113a7c
801044e9:	00 00 00 
    ioapicid = 0;
801044ec:	c6 05 60 3b 11 80 00 	movb   $0x0,0x80113b60
    return;
801044f3:	eb 41                	jmp    80104536 <mpinit+0x1c5>
  }

  if(mp->imcrp){
801044f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044f8:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801044fc:	84 c0                	test   %al,%al
801044fe:	74 36                	je     80104536 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104500:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80104507:	00 
80104508:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
8010450f:	e8 0d fc ff ff       	call   80104121 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104514:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
8010451b:	e8 e4 fb ff ff       	call   80104104 <inb>
80104520:	83 c8 01             	or     $0x1,%eax
80104523:	0f b6 c0             	movzbl %al,%eax
80104526:	89 44 24 04          	mov    %eax,0x4(%esp)
8010452a:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80104531:	e8 eb fb ff ff       	call   80104121 <outb>
  }
}
80104536:	c9                   	leave  
80104537:	c3                   	ret    

80104538 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104538:	55                   	push   %ebp
80104539:	89 e5                	mov    %esp,%ebp
8010453b:	83 ec 08             	sub    $0x8,%esp
8010453e:	8b 55 08             	mov    0x8(%ebp),%edx
80104541:	8b 45 0c             	mov    0xc(%ebp),%eax
80104544:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104548:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010454b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010454f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104553:	ee                   	out    %al,(%dx)
}
80104554:	c9                   	leave  
80104555:	c3                   	ret    

80104556 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104556:	55                   	push   %ebp
80104557:	89 e5                	mov    %esp,%ebp
80104559:	83 ec 0c             	sub    $0xc,%esp
8010455c:	8b 45 08             	mov    0x8(%ebp),%eax
8010455f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104563:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104567:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
8010456d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104571:	0f b6 c0             	movzbl %al,%eax
80104574:	89 44 24 04          	mov    %eax,0x4(%esp)
80104578:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010457f:	e8 b4 ff ff ff       	call   80104538 <outb>
  outb(IO_PIC2+1, mask >> 8);
80104584:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104588:	66 c1 e8 08          	shr    $0x8,%ax
8010458c:	0f b6 c0             	movzbl %al,%eax
8010458f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104593:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
8010459a:	e8 99 ff ff ff       	call   80104538 <outb>
}
8010459f:	c9                   	leave  
801045a0:	c3                   	ret    

801045a1 <picenable>:

void
picenable(int irq)
{
801045a1:	55                   	push   %ebp
801045a2:	89 e5                	mov    %esp,%ebp
801045a4:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
801045a7:	8b 45 08             	mov    0x8(%ebp),%eax
801045aa:	ba 01 00 00 00       	mov    $0x1,%edx
801045af:	89 c1                	mov    %eax,%ecx
801045b1:	d3 e2                	shl    %cl,%edx
801045b3:	89 d0                	mov    %edx,%eax
801045b5:	f7 d0                	not    %eax
801045b7:	89 c2                	mov    %eax,%edx
801045b9:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801045c0:	21 d0                	and    %edx,%eax
801045c2:	0f b7 c0             	movzwl %ax,%eax
801045c5:	89 04 24             	mov    %eax,(%esp)
801045c8:	e8 89 ff ff ff       	call   80104556 <picsetmask>
}
801045cd:	c9                   	leave  
801045ce:	c3                   	ret    

801045cf <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
801045cf:	55                   	push   %ebp
801045d0:	89 e5                	mov    %esp,%ebp
801045d2:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801045d5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
801045dc:	00 
801045dd:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
801045e4:	e8 4f ff ff ff       	call   80104538 <outb>
  outb(IO_PIC2+1, 0xFF);
801045e9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
801045f0:	00 
801045f1:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
801045f8:	e8 3b ff ff ff       	call   80104538 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
801045fd:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80104604:	00 
80104605:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010460c:	e8 27 ff ff ff       	call   80104538 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104611:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80104618:	00 
80104619:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104620:	e8 13 ff ff ff       	call   80104538 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104625:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
8010462c:	00 
8010462d:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104634:	e8 ff fe ff ff       	call   80104538 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104639:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80104640:	00 
80104641:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104648:	e8 eb fe ff ff       	call   80104538 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
8010464d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80104654:	00 
80104655:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010465c:	e8 d7 fe ff ff       	call   80104538 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104661:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80104668:	00 
80104669:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104670:	e8 c3 fe ff ff       	call   80104538 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104675:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010467c:	00 
8010467d:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104684:	e8 af fe ff ff       	call   80104538 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104689:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80104690:	00 
80104691:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104698:	e8 9b fe ff ff       	call   80104538 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010469d:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
801046a4:	00 
801046a5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801046ac:	e8 87 fe ff ff       	call   80104538 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
801046b1:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801046b8:	00 
801046b9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801046c0:	e8 73 fe ff ff       	call   80104538 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
801046c5:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
801046cc:	00 
801046cd:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801046d4:	e8 5f fe ff ff       	call   80104538 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
801046d9:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801046e0:	00 
801046e1:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801046e8:	e8 4b fe ff ff       	call   80104538 <outb>

  if(irqmask != 0xFFFF)
801046ed:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801046f4:	66 83 f8 ff          	cmp    $0xffff,%ax
801046f8:	74 12                	je     8010470c <picinit+0x13d>
    picsetmask(irqmask);
801046fa:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104701:	0f b7 c0             	movzwl %ax,%eax
80104704:	89 04 24             	mov    %eax,(%esp)
80104707:	e8 4a fe ff ff       	call   80104556 <picsetmask>
}
8010470c:	c9                   	leave  
8010470d:	c3                   	ret    

8010470e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010470e:	55                   	push   %ebp
8010470f:	89 e5                	mov    %esp,%ebp
80104711:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80104714:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010471b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010471e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104724:	8b 45 0c             	mov    0xc(%ebp),%eax
80104727:	8b 10                	mov    (%eax),%edx
80104729:	8b 45 08             	mov    0x8(%ebp),%eax
8010472c:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010472e:	e8 54 cf ff ff       	call   80101687 <filealloc>
80104733:	8b 55 08             	mov    0x8(%ebp),%edx
80104736:	89 02                	mov    %eax,(%edx)
80104738:	8b 45 08             	mov    0x8(%ebp),%eax
8010473b:	8b 00                	mov    (%eax),%eax
8010473d:	85 c0                	test   %eax,%eax
8010473f:	0f 84 c8 00 00 00    	je     8010480d <pipealloc+0xff>
80104745:	e8 3d cf ff ff       	call   80101687 <filealloc>
8010474a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010474d:	89 02                	mov    %eax,(%edx)
8010474f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104752:	8b 00                	mov    (%eax),%eax
80104754:	85 c0                	test   %eax,%eax
80104756:	0f 84 b1 00 00 00    	je     8010480d <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010475c:	e8 7d eb ff ff       	call   801032de <kalloc>
80104761:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104764:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104768:	75 05                	jne    8010476f <pipealloc+0x61>
    goto bad;
8010476a:	e9 9e 00 00 00       	jmp    8010480d <pipealloc+0xff>
  p->readopen = 1;
8010476f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104772:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104779:	00 00 00 
  p->writeopen = 1;
8010477c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477f:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104786:	00 00 00 
  p->nwrite = 0;
80104789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478c:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104793:	00 00 00 
  p->nread = 0;
80104796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104799:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801047a0:	00 00 00 
  initlock(&p->lock, "pipe");
801047a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a6:	c7 44 24 04 24 92 10 	movl   $0x80109224,0x4(%esp)
801047ad:	80 
801047ae:	89 04 24             	mov    %eax,(%esp)
801047b1:	e8 03 10 00 00       	call   801057b9 <initlock>
  (*f0)->type = FD_PIPE;
801047b6:	8b 45 08             	mov    0x8(%ebp),%eax
801047b9:	8b 00                	mov    (%eax),%eax
801047bb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801047c1:	8b 45 08             	mov    0x8(%ebp),%eax
801047c4:	8b 00                	mov    (%eax),%eax
801047c6:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801047ca:	8b 45 08             	mov    0x8(%ebp),%eax
801047cd:	8b 00                	mov    (%eax),%eax
801047cf:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801047d3:	8b 45 08             	mov    0x8(%ebp),%eax
801047d6:	8b 00                	mov    (%eax),%eax
801047d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047db:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801047de:	8b 45 0c             	mov    0xc(%ebp),%eax
801047e1:	8b 00                	mov    (%eax),%eax
801047e3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801047e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801047ec:	8b 00                	mov    (%eax),%eax
801047ee:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801047f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801047f5:	8b 00                	mov    (%eax),%eax
801047f7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801047fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801047fe:	8b 00                	mov    (%eax),%eax
80104800:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104803:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104806:	b8 00 00 00 00       	mov    $0x0,%eax
8010480b:	eb 42                	jmp    8010484f <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
8010480d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104811:	74 0b                	je     8010481e <pipealloc+0x110>
    kfree((char*)p);
80104813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104816:	89 04 24             	mov    %eax,(%esp)
80104819:	e8 27 ea ff ff       	call   80103245 <kfree>
  if(*f0)
8010481e:	8b 45 08             	mov    0x8(%ebp),%eax
80104821:	8b 00                	mov    (%eax),%eax
80104823:	85 c0                	test   %eax,%eax
80104825:	74 0d                	je     80104834 <pipealloc+0x126>
    fileclose(*f0);
80104827:	8b 45 08             	mov    0x8(%ebp),%eax
8010482a:	8b 00                	mov    (%eax),%eax
8010482c:	89 04 24             	mov    %eax,(%esp)
8010482f:	e8 fb ce ff ff       	call   8010172f <fileclose>
  if(*f1)
80104834:	8b 45 0c             	mov    0xc(%ebp),%eax
80104837:	8b 00                	mov    (%eax),%eax
80104839:	85 c0                	test   %eax,%eax
8010483b:	74 0d                	je     8010484a <pipealloc+0x13c>
    fileclose(*f1);
8010483d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104840:	8b 00                	mov    (%eax),%eax
80104842:	89 04 24             	mov    %eax,(%esp)
80104845:	e8 e5 ce ff ff       	call   8010172f <fileclose>
  return -1;
8010484a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010484f:	c9                   	leave  
80104850:	c3                   	ret    

80104851 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104851:	55                   	push   %ebp
80104852:	89 e5                	mov    %esp,%ebp
80104854:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104857:	8b 45 08             	mov    0x8(%ebp),%eax
8010485a:	89 04 24             	mov    %eax,(%esp)
8010485d:	e8 78 0f 00 00       	call   801057da <acquire>
  if(writable){
80104862:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104866:	74 1f                	je     80104887 <pipeclose+0x36>
    p->writeopen = 0;
80104868:	8b 45 08             	mov    0x8(%ebp),%eax
8010486b:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104872:	00 00 00 
    wakeup(&p->nread);
80104875:	8b 45 08             	mov    0x8(%ebp),%eax
80104878:	05 34 02 00 00       	add    $0x234,%eax
8010487d:	89 04 24             	mov    %eax,(%esp)
80104880:	e8 e2 0c 00 00       	call   80105567 <wakeup>
80104885:	eb 1d                	jmp    801048a4 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104887:	8b 45 08             	mov    0x8(%ebp),%eax
8010488a:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104891:	00 00 00 
    wakeup(&p->nwrite);
80104894:	8b 45 08             	mov    0x8(%ebp),%eax
80104897:	05 38 02 00 00       	add    $0x238,%eax
8010489c:	89 04 24             	mov    %eax,(%esp)
8010489f:	e8 c3 0c 00 00       	call   80105567 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801048a4:	8b 45 08             	mov    0x8(%ebp),%eax
801048a7:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801048ad:	85 c0                	test   %eax,%eax
801048af:	75 25                	jne    801048d6 <pipeclose+0x85>
801048b1:	8b 45 08             	mov    0x8(%ebp),%eax
801048b4:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801048ba:	85 c0                	test   %eax,%eax
801048bc:	75 18                	jne    801048d6 <pipeclose+0x85>
    release(&p->lock);
801048be:	8b 45 08             	mov    0x8(%ebp),%eax
801048c1:	89 04 24             	mov    %eax,(%esp)
801048c4:	e8 73 0f 00 00       	call   8010583c <release>
    kfree((char*)p);
801048c9:	8b 45 08             	mov    0x8(%ebp),%eax
801048cc:	89 04 24             	mov    %eax,(%esp)
801048cf:	e8 71 e9 ff ff       	call   80103245 <kfree>
801048d4:	eb 0b                	jmp    801048e1 <pipeclose+0x90>
  } else
    release(&p->lock);
801048d6:	8b 45 08             	mov    0x8(%ebp),%eax
801048d9:	89 04 24             	mov    %eax,(%esp)
801048dc:	e8 5b 0f 00 00       	call   8010583c <release>
}
801048e1:	c9                   	leave  
801048e2:	c3                   	ret    

801048e3 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801048e3:	55                   	push   %ebp
801048e4:	89 e5                	mov    %esp,%ebp
801048e6:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801048e9:	8b 45 08             	mov    0x8(%ebp),%eax
801048ec:	89 04 24             	mov    %eax,(%esp)
801048ef:	e8 e6 0e 00 00       	call   801057da <acquire>
  for(i = 0; i < n; i++){
801048f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801048fb:	e9 a6 00 00 00       	jmp    801049a6 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104900:	eb 57                	jmp    80104959 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80104902:	8b 45 08             	mov    0x8(%ebp),%eax
80104905:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010490b:	85 c0                	test   %eax,%eax
8010490d:	74 0d                	je     8010491c <pipewrite+0x39>
8010490f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104915:	8b 40 24             	mov    0x24(%eax),%eax
80104918:	85 c0                	test   %eax,%eax
8010491a:	74 15                	je     80104931 <pipewrite+0x4e>
        release(&p->lock);
8010491c:	8b 45 08             	mov    0x8(%ebp),%eax
8010491f:	89 04 24             	mov    %eax,(%esp)
80104922:	e8 15 0f 00 00       	call   8010583c <release>
        return -1;
80104927:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010492c:	e9 9f 00 00 00       	jmp    801049d0 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80104931:	8b 45 08             	mov    0x8(%ebp),%eax
80104934:	05 34 02 00 00       	add    $0x234,%eax
80104939:	89 04 24             	mov    %eax,(%esp)
8010493c:	e8 26 0c 00 00       	call   80105567 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104941:	8b 45 08             	mov    0x8(%ebp),%eax
80104944:	8b 55 08             	mov    0x8(%ebp),%edx
80104947:	81 c2 38 02 00 00    	add    $0x238,%edx
8010494d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104951:	89 14 24             	mov    %edx,(%esp)
80104954:	e8 32 0b 00 00       	call   8010548b <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104959:	8b 45 08             	mov    0x8(%ebp),%eax
8010495c:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104962:	8b 45 08             	mov    0x8(%ebp),%eax
80104965:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010496b:	05 00 02 00 00       	add    $0x200,%eax
80104970:	39 c2                	cmp    %eax,%edx
80104972:	74 8e                	je     80104902 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104974:	8b 45 08             	mov    0x8(%ebp),%eax
80104977:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010497d:	8d 48 01             	lea    0x1(%eax),%ecx
80104980:	8b 55 08             	mov    0x8(%ebp),%edx
80104983:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104989:	25 ff 01 00 00       	and    $0x1ff,%eax
8010498e:	89 c1                	mov    %eax,%ecx
80104990:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104993:	8b 45 0c             	mov    0xc(%ebp),%eax
80104996:	01 d0                	add    %edx,%eax
80104998:	0f b6 10             	movzbl (%eax),%edx
8010499b:	8b 45 08             	mov    0x8(%ebp),%eax
8010499e:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801049a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801049a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a9:	3b 45 10             	cmp    0x10(%ebp),%eax
801049ac:	0f 8c 4e ff ff ff    	jl     80104900 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801049b2:	8b 45 08             	mov    0x8(%ebp),%eax
801049b5:	05 34 02 00 00       	add    $0x234,%eax
801049ba:	89 04 24             	mov    %eax,(%esp)
801049bd:	e8 a5 0b 00 00       	call   80105567 <wakeup>
  release(&p->lock);
801049c2:	8b 45 08             	mov    0x8(%ebp),%eax
801049c5:	89 04 24             	mov    %eax,(%esp)
801049c8:	e8 6f 0e 00 00       	call   8010583c <release>
  return n;
801049cd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801049d0:	c9                   	leave  
801049d1:	c3                   	ret    

801049d2 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801049d2:	55                   	push   %ebp
801049d3:	89 e5                	mov    %esp,%ebp
801049d5:	53                   	push   %ebx
801049d6:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801049d9:	8b 45 08             	mov    0x8(%ebp),%eax
801049dc:	89 04 24             	mov    %eax,(%esp)
801049df:	e8 f6 0d 00 00       	call   801057da <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801049e4:	eb 3a                	jmp    80104a20 <piperead+0x4e>
    if(proc->killed){
801049e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ec:	8b 40 24             	mov    0x24(%eax),%eax
801049ef:	85 c0                	test   %eax,%eax
801049f1:	74 15                	je     80104a08 <piperead+0x36>
      release(&p->lock);
801049f3:	8b 45 08             	mov    0x8(%ebp),%eax
801049f6:	89 04 24             	mov    %eax,(%esp)
801049f9:	e8 3e 0e 00 00       	call   8010583c <release>
      return -1;
801049fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a03:	e9 b5 00 00 00       	jmp    80104abd <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104a08:	8b 45 08             	mov    0x8(%ebp),%eax
80104a0b:	8b 55 08             	mov    0x8(%ebp),%edx
80104a0e:	81 c2 34 02 00 00    	add    $0x234,%edx
80104a14:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a18:	89 14 24             	mov    %edx,(%esp)
80104a1b:	e8 6b 0a 00 00       	call   8010548b <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104a20:	8b 45 08             	mov    0x8(%ebp),%eax
80104a23:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104a29:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104a32:	39 c2                	cmp    %eax,%edx
80104a34:	75 0d                	jne    80104a43 <piperead+0x71>
80104a36:	8b 45 08             	mov    0x8(%ebp),%eax
80104a39:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104a3f:	85 c0                	test   %eax,%eax
80104a41:	75 a3                	jne    801049e6 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104a43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a4a:	eb 4b                	jmp    80104a97 <piperead+0xc5>
    if(p->nread == p->nwrite)
80104a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104a55:	8b 45 08             	mov    0x8(%ebp),%eax
80104a58:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104a5e:	39 c2                	cmp    %eax,%edx
80104a60:	75 02                	jne    80104a64 <piperead+0x92>
      break;
80104a62:	eb 3b                	jmp    80104a9f <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104a64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a67:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a6a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a70:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104a76:	8d 48 01             	lea    0x1(%eax),%ecx
80104a79:	8b 55 08             	mov    0x8(%ebp),%edx
80104a7c:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104a82:	25 ff 01 00 00       	and    $0x1ff,%eax
80104a87:	89 c2                	mov    %eax,%edx
80104a89:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8c:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104a91:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104a93:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9a:	3b 45 10             	cmp    0x10(%ebp),%eax
80104a9d:	7c ad                	jl     80104a4c <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa2:	05 38 02 00 00       	add    $0x238,%eax
80104aa7:	89 04 24             	mov    %eax,(%esp)
80104aaa:	e8 b8 0a 00 00       	call   80105567 <wakeup>
  release(&p->lock);
80104aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab2:	89 04 24             	mov    %eax,(%esp)
80104ab5:	e8 82 0d 00 00       	call   8010583c <release>
  return i;
80104aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104abd:	83 c4 24             	add    $0x24,%esp
80104ac0:	5b                   	pop    %ebx
80104ac1:	5d                   	pop    %ebp
80104ac2:	c3                   	ret    

80104ac3 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104ac3:	55                   	push   %ebp
80104ac4:	89 e5                	mov    %esp,%ebp
80104ac6:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ac9:	9c                   	pushf  
80104aca:	58                   	pop    %eax
80104acb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104ace:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ad1:	c9                   	leave  
80104ad2:	c3                   	ret    

80104ad3 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104ad3:	55                   	push   %ebp
80104ad4:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ad6:	fb                   	sti    
}
80104ad7:	5d                   	pop    %ebp
80104ad8:	c3                   	ret    

80104ad9 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104ad9:	55                   	push   %ebp
80104ada:	89 e5                	mov    %esp,%ebp
80104adc:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104adf:	c7 44 24 04 29 92 10 	movl   $0x80109229,0x4(%esp)
80104ae6:	80 
80104ae7:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80104aee:	e8 c6 0c 00 00       	call   801057b9 <initlock>
}
80104af3:	c9                   	leave  
80104af4:	c3                   	ret    

80104af5 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104af5:	55                   	push   %ebp
80104af6:	89 e5                	mov    %esp,%ebp
80104af8:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104afb:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80104b02:	e8 d3 0c 00 00       	call   801057da <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b07:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
80104b0e:	eb 53                	jmp    80104b63 <allocproc+0x6e>
    if(p->state == UNUSED)
80104b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b13:	8b 40 0c             	mov    0xc(%eax),%eax
80104b16:	85 c0                	test   %eax,%eax
80104b18:	75 42                	jne    80104b5c <allocproc+0x67>
      goto found;
80104b1a:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1e:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104b25:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104b2a:	8d 50 01             	lea    0x1(%eax),%edx
80104b2d:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104b33:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b36:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104b39:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80104b40:	e8 f7 0c 00 00       	call   8010583c <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104b45:	e8 94 e7 ff ff       	call   801032de <kalloc>
80104b4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b4d:	89 42 08             	mov    %eax,0x8(%edx)
80104b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b53:	8b 40 08             	mov    0x8(%eax),%eax
80104b56:	85 c0                	test   %eax,%eax
80104b58:	75 36                	jne    80104b90 <allocproc+0x9b>
80104b5a:	eb 23                	jmp    80104b7f <allocproc+0x8a>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b5c:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104b63:	81 7d f4 b4 64 11 80 	cmpl   $0x801164b4,-0xc(%ebp)
80104b6a:	72 a4                	jb     80104b10 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104b6c:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80104b73:	e8 c4 0c 00 00       	call   8010583c <release>
  return 0;
80104b78:	b8 00 00 00 00       	mov    $0x0,%eax
80104b7d:	eb 76                	jmp    80104bf5 <allocproc+0x100>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b82:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104b89:	b8 00 00 00 00       	mov    $0x0,%eax
80104b8e:	eb 65                	jmp    80104bf5 <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
80104b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b93:	8b 40 08             	mov    0x8(%eax),%eax
80104b96:	05 00 10 00 00       	add    $0x1000,%eax
80104b9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104b9e:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ba8:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104bab:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104baf:	ba 78 6f 10 80       	mov    $0x80106f78,%edx
80104bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bb7:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104bb9:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104bc3:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc9:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bcc:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104bd3:	00 
80104bd4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104bdb:	00 
80104bdc:	89 04 24             	mov    %eax,(%esp)
80104bdf:	e8 4a 0e 00 00       	call   80105a2e <memset>
  p->context->eip = (uint)forkret;
80104be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be7:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bea:	ba 4c 54 10 80       	mov    $0x8010544c,%edx
80104bef:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104bf5:	c9                   	leave  
80104bf6:	c3                   	ret    

80104bf7 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104bf7:	55                   	push   %ebp
80104bf8:	89 e5                	mov    %esp,%ebp
80104bfa:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104bfd:	e8 f3 fe ff ff       	call   80104af5 <allocproc>
80104c02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c08:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
80104c0d:	e8 5f 3a 00 00       	call   80108671 <setupkvm>
80104c12:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c15:	89 42 04             	mov    %eax,0x4(%edx)
80104c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1b:	8b 40 04             	mov    0x4(%eax),%eax
80104c1e:	85 c0                	test   %eax,%eax
80104c20:	75 0c                	jne    80104c2e <userinit+0x37>
    panic("userinit: out of memory?");
80104c22:	c7 04 24 30 92 10 80 	movl   $0x80109230,(%esp)
80104c29:	e8 0c b9 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104c2e:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c36:	8b 40 04             	mov    0x4(%eax),%eax
80104c39:	89 54 24 08          	mov    %edx,0x8(%esp)
80104c3d:	c7 44 24 04 e0 c4 10 	movl   $0x8010c4e0,0x4(%esp)
80104c44:	80 
80104c45:	89 04 24             	mov    %eax,(%esp)
80104c48:	e8 7c 3c 00 00       	call   801088c9 <inituvm>
  p->sz = PGSIZE;
80104c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c50:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c59:	8b 40 18             	mov    0x18(%eax),%eax
80104c5c:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104c63:	00 
80104c64:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104c6b:	00 
80104c6c:	89 04 24             	mov    %eax,(%esp)
80104c6f:	e8 ba 0d 00 00       	call   80105a2e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c77:	8b 40 18             	mov    0x18(%eax),%eax
80104c7a:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c83:	8b 40 18             	mov    0x18(%eax),%eax
80104c86:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8f:	8b 40 18             	mov    0x18(%eax),%eax
80104c92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c95:	8b 52 18             	mov    0x18(%edx),%edx
80104c98:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104c9c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca3:	8b 40 18             	mov    0x18(%eax),%eax
80104ca6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ca9:	8b 52 18             	mov    0x18(%edx),%edx
80104cac:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104cb0:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb7:	8b 40 18             	mov    0x18(%eax),%eax
80104cba:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc4:	8b 40 18             	mov    0x18(%eax),%eax
80104cc7:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd1:	8b 40 18             	mov    0x18(%eax),%eax
80104cd4:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cde:	83 c0 6c             	add    $0x6c,%eax
80104ce1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104ce8:	00 
80104ce9:	c7 44 24 04 49 92 10 	movl   $0x80109249,0x4(%esp)
80104cf0:	80 
80104cf1:	89 04 24             	mov    %eax,(%esp)
80104cf4:	e8 55 0f 00 00       	call   80105c4e <safestrcpy>
  p->cwd = namei("/");
80104cf9:	c7 04 24 52 92 10 80 	movl   $0x80109252,(%esp)
80104d00:	e8 c6 de ff ff       	call   80102bcb <namei>
80104d05:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d08:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104d15:	c9                   	leave  
80104d16:	c3                   	ret    

80104d17 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104d17:	55                   	push   %ebp
80104d18:	89 e5                	mov    %esp,%ebp
80104d1a:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104d1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d23:	8b 00                	mov    (%eax),%eax
80104d25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104d28:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104d2c:	7e 34                	jle    80104d62 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104d2e:	8b 55 08             	mov    0x8(%ebp),%edx
80104d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d34:	01 c2                	add    %eax,%edx
80104d36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d3c:	8b 40 04             	mov    0x4(%eax),%eax
80104d3f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104d43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d46:	89 54 24 04          	mov    %edx,0x4(%esp)
80104d4a:	89 04 24             	mov    %eax,(%esp)
80104d4d:	e8 ed 3c 00 00       	call   80108a3f <allocuvm>
80104d52:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104d59:	75 41                	jne    80104d9c <growproc+0x85>
      return -1;
80104d5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d60:	eb 58                	jmp    80104dba <growproc+0xa3>
  } else if(n < 0){
80104d62:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104d66:	79 34                	jns    80104d9c <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104d68:	8b 55 08             	mov    0x8(%ebp),%edx
80104d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6e:	01 c2                	add    %eax,%edx
80104d70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d76:	8b 40 04             	mov    0x4(%eax),%eax
80104d79:	89 54 24 08          	mov    %edx,0x8(%esp)
80104d7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d80:	89 54 24 04          	mov    %edx,0x4(%esp)
80104d84:	89 04 24             	mov    %eax,(%esp)
80104d87:	e8 8d 3d 00 00       	call   80108b19 <deallocuvm>
80104d8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104d93:	75 07                	jne    80104d9c <growproc+0x85>
      return -1;
80104d95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d9a:	eb 1e                	jmp    80104dba <growproc+0xa3>
  }
  proc->sz = sz;
80104d9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104da5:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104da7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dad:	89 04 24             	mov    %eax,(%esp)
80104db0:	e8 ad 39 00 00       	call   80108762 <switchuvm>
  return 0;
80104db5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104dba:	c9                   	leave  
80104dbb:	c3                   	ret    

80104dbc <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104dbc:	55                   	push   %ebp
80104dbd:	89 e5                	mov    %esp,%ebp
80104dbf:	57                   	push   %edi
80104dc0:	56                   	push   %esi
80104dc1:	53                   	push   %ebx
80104dc2:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104dc5:	e8 2b fd ff ff       	call   80104af5 <allocproc>
80104dca:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104dcd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104dd1:	75 0a                	jne    80104ddd <fork+0x21>
    return -1;
80104dd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dd8:	e9 5f 01 00 00       	jmp    80104f3c <fork+0x180>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104ddd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de3:	8b 10                	mov    (%eax),%edx
80104de5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104deb:	8b 40 04             	mov    0x4(%eax),%eax
80104dee:	89 54 24 04          	mov    %edx,0x4(%esp)
80104df2:	89 04 24             	mov    %eax,(%esp)
80104df5:	e8 bb 3e 00 00       	call   80108cb5 <copyuvm>
80104dfa:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104dfd:	89 42 04             	mov    %eax,0x4(%edx)
80104e00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e03:	8b 40 04             	mov    0x4(%eax),%eax
80104e06:	85 c0                	test   %eax,%eax
80104e08:	75 2c                	jne    80104e36 <fork+0x7a>
    kfree(np->kstack);
80104e0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e0d:	8b 40 08             	mov    0x8(%eax),%eax
80104e10:	89 04 24             	mov    %eax,(%esp)
80104e13:	e8 2d e4 ff ff       	call   80103245 <kfree>
    np->kstack = 0;
80104e18:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e1b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104e22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e25:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104e2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e31:	e9 06 01 00 00       	jmp    80104f3c <fork+0x180>
  }
  np->sz = proc->sz;
80104e36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e3c:	8b 10                	mov    (%eax),%edx
80104e3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e41:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104e43:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e4d:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104e50:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e53:	8b 50 18             	mov    0x18(%eax),%edx
80104e56:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e5c:	8b 40 18             	mov    0x18(%eax),%eax
80104e5f:	89 c3                	mov    %eax,%ebx
80104e61:	b8 13 00 00 00       	mov    $0x13,%eax
80104e66:	89 d7                	mov    %edx,%edi
80104e68:	89 de                	mov    %ebx,%esi
80104e6a:	89 c1                	mov    %eax,%ecx
80104e6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104e6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e71:	8b 40 18             	mov    0x18(%eax),%eax
80104e74:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104e7b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104e82:	eb 3d                	jmp    80104ec1 <fork+0x105>
    if(proc->ofile[i])
80104e84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e8a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104e8d:	83 c2 08             	add    $0x8,%edx
80104e90:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e94:	85 c0                	test   %eax,%eax
80104e96:	74 25                	je     80104ebd <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104e98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e9e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104ea1:	83 c2 08             	add    $0x8,%edx
80104ea4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ea8:	89 04 24             	mov    %eax,(%esp)
80104eab:	e8 37 c8 ff ff       	call   801016e7 <filedup>
80104eb0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104eb3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104eb6:	83 c1 08             	add    $0x8,%ecx
80104eb9:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104ebd:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104ec1:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104ec5:	7e bd                	jle    80104e84 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104ec7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ecd:	8b 40 68             	mov    0x68(%eax),%eax
80104ed0:	89 04 24             	mov    %eax,(%esp)
80104ed3:	e8 10 d1 ff ff       	call   80101fe8 <idup>
80104ed8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104edb:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104ede:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee4:	8d 50 6c             	lea    0x6c(%eax),%edx
80104ee7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104eea:	83 c0 6c             	add    $0x6c,%eax
80104eed:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104ef4:	00 
80104ef5:	89 54 24 04          	mov    %edx,0x4(%esp)
80104ef9:	89 04 24             	mov    %eax,(%esp)
80104efc:	e8 4d 0d 00 00       	call   80105c4e <safestrcpy>
 
  pid = np->pid;
80104f01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f04:	8b 40 10             	mov    0x10(%eax),%eax
80104f07:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104f0a:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80104f11:	e8 c4 08 00 00       	call   801057da <acquire>
  np->state = RUNNABLE;
80104f16:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f19:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  //************************************
  np->ctime=ticks;
80104f20:	a1 00 6d 11 80       	mov    0x80116d00,%eax
80104f25:	89 c2                	mov    %eax,%edx
80104f27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f2a:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&ptable.lock);
80104f2d:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80104f34:	e8 03 09 00 00       	call   8010583c <release>
  
  return pid;
80104f39:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104f3c:	83 c4 2c             	add    $0x2c,%esp
80104f3f:	5b                   	pop    %ebx
80104f40:	5e                   	pop    %esi
80104f41:	5f                   	pop    %edi
80104f42:	5d                   	pop    %ebp
80104f43:	c3                   	ret    

80104f44 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104f44:	55                   	push   %ebp
80104f45:	89 e5                	mov    %esp,%ebp
80104f47:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104f4a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f51:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104f56:	39 c2                	cmp    %eax,%edx
80104f58:	75 0c                	jne    80104f66 <exit+0x22>
    panic("init exiting");
80104f5a:	c7 04 24 54 92 10 80 	movl   $0x80109254,(%esp)
80104f61:	e8 d4 b5 ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104f66:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104f6d:	eb 44                	jmp    80104fb3 <exit+0x6f>
    if(proc->ofile[fd]){
80104f6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f75:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f78:	83 c2 08             	add    $0x8,%edx
80104f7b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f7f:	85 c0                	test   %eax,%eax
80104f81:	74 2c                	je     80104faf <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104f83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f89:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f8c:	83 c2 08             	add    $0x8,%edx
80104f8f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f93:	89 04 24             	mov    %eax,(%esp)
80104f96:	e8 94 c7 ff ff       	call   8010172f <fileclose>
      proc->ofile[fd] = 0;
80104f9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fa1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fa4:	83 c2 08             	add    $0x8,%edx
80104fa7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104fae:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104faf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104fb3:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104fb7:	7e b6                	jle    80104f6f <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104fb9:	e8 44 ec ff ff       	call   80103c02 <begin_op>
  iput(proc->cwd);
80104fbe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fc4:	8b 40 68             	mov    0x68(%eax),%eax
80104fc7:	89 04 24             	mov    %eax,(%esp)
80104fca:	e8 04 d2 ff ff       	call   801021d3 <iput>
  end_op();
80104fcf:	e8 b2 ec ff ff       	call   80103c86 <end_op>
  proc->cwd = 0;
80104fd4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fda:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104fe1:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80104fe8:	e8 ed 07 00 00       	call   801057da <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104fed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff3:	8b 40 14             	mov    0x14(%eax),%eax
80104ff6:	89 04 24             	mov    %eax,(%esp)
80104ff9:	e8 28 05 00 00       	call   80105526 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ffe:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
80105005:	eb 3b                	jmp    80105042 <exit+0xfe>
    if(p->parent == proc){
80105007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500a:	8b 50 14             	mov    0x14(%eax),%edx
8010500d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105013:	39 c2                	cmp    %eax,%edx
80105015:	75 24                	jne    8010503b <exit+0xf7>
      p->parent = initproc;
80105017:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
8010501d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105020:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105026:	8b 40 0c             	mov    0xc(%eax),%eax
80105029:	83 f8 05             	cmp    $0x5,%eax
8010502c:	75 0d                	jne    8010503b <exit+0xf7>
        wakeup1(initproc);
8010502e:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80105033:	89 04 24             	mov    %eax,(%esp)
80105036:	e8 eb 04 00 00       	call   80105526 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010503b:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80105042:	81 7d f4 b4 64 11 80 	cmpl   $0x801164b4,-0xc(%ebp)
80105049:	72 bc                	jb     80105007 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
8010504b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105051:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80105058:	e8 0b 03 00 00       	call   80105368 <sched>
  panic("zombie exit");
8010505d:	c7 04 24 61 92 10 80 	movl   $0x80109261,(%esp)
80105064:	e8 d1 b4 ff ff       	call   8010053a <panic>

80105069 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80105069:	55                   	push   %ebp
8010506a:	89 e5                	mov    %esp,%ebp
8010506c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010506f:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105076:	e8 5f 07 00 00       	call   801057da <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010507b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105082:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
80105089:	e9 9d 00 00 00       	jmp    8010512b <wait+0xc2>
      if(p->parent != proc)
8010508e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105091:	8b 50 14             	mov    0x14(%eax),%edx
80105094:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010509a:	39 c2                	cmp    %eax,%edx
8010509c:	74 05                	je     801050a3 <wait+0x3a>
        continue;
8010509e:	e9 81 00 00 00       	jmp    80105124 <wait+0xbb>
      havekids = 1;
801050a3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801050aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ad:	8b 40 0c             	mov    0xc(%eax),%eax
801050b0:	83 f8 05             	cmp    $0x5,%eax
801050b3:	75 6f                	jne    80105124 <wait+0xbb>
        // Found one.
        pid = p->pid;
801050b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b8:	8b 40 10             	mov    0x10(%eax),%eax
801050bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801050be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c1:	8b 40 08             	mov    0x8(%eax),%eax
801050c4:	89 04 24             	mov    %eax,(%esp)
801050c7:	e8 79 e1 ff ff       	call   80103245 <kfree>
        p->kstack = 0;
801050cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050cf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801050d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d9:	8b 40 04             	mov    0x4(%eax),%eax
801050dc:	89 04 24             	mov    %eax,(%esp)
801050df:	e8 f1 3a 00 00       	call   80108bd5 <freevm>
        p->state = UNUSED;
801050e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801050ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801050f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050fb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105105:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80105109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010510c:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105113:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010511a:	e8 1d 07 00 00       	call   8010583c <release>
        return pid;
8010511f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105122:	eb 55                	jmp    80105179 <wait+0x110>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105124:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
8010512b:	81 7d f4 b4 64 11 80 	cmpl   $0x801164b4,-0xc(%ebp)
80105132:	0f 82 56 ff ff ff    	jb     8010508e <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105138:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010513c:	74 0d                	je     8010514b <wait+0xe2>
8010513e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105144:	8b 40 24             	mov    0x24(%eax),%eax
80105147:	85 c0                	test   %eax,%eax
80105149:	74 13                	je     8010515e <wait+0xf5>
      release(&ptable.lock);
8010514b:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105152:	e8 e5 06 00 00       	call   8010583c <release>
      return -1;
80105157:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010515c:	eb 1b                	jmp    80105179 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010515e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105164:	c7 44 24 04 80 41 11 	movl   $0x80114180,0x4(%esp)
8010516b:	80 
8010516c:	89 04 24             	mov    %eax,(%esp)
8010516f:	e8 17 03 00 00       	call   8010548b <sleep>
  }
80105174:	e9 02 ff ff ff       	jmp    8010507b <wait+0x12>
}
80105179:	c9                   	leave  
8010517a:	c3                   	ret    

8010517b <wait2>:

int wait2(int* retime,int* rutime, int* stime){
8010517b:	55                   	push   %ebp
8010517c:	89 e5                	mov    %esp,%ebp
8010517e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80105181:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105188:	e8 4d 06 00 00       	call   801057da <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010518d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105194:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
8010519b:	e9 dd 00 00 00       	jmp    8010527d <wait2+0x102>
      if(p->parent != proc)
801051a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a3:	8b 50 14             	mov    0x14(%eax),%edx
801051a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051ac:	39 c2                	cmp    %eax,%edx
801051ae:	74 05                	je     801051b5 <wait2+0x3a>
        continue;
801051b0:	e9 c1 00 00 00       	jmp    80105276 <wait2+0xfb>
      havekids = 1;
801051b5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801051bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051bf:	8b 40 0c             	mov    0xc(%eax),%eax
801051c2:	83 f8 05             	cmp    $0x5,%eax
801051c5:	0f 85 ab 00 00 00    	jne    80105276 <wait2+0xfb>
        // Found one.
        pid = p->pid;
801051cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ce:	8b 40 10             	mov    0x10(%eax),%eax
801051d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801051d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d7:	8b 40 08             	mov    0x8(%eax),%eax
801051da:	89 04 24             	mov    %eax,(%esp)
801051dd:	e8 63 e0 ff ff       	call   80103245 <kfree>
        p->kstack = 0;
801051e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801051ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ef:	8b 40 04             	mov    0x4(%eax),%eax
801051f2:	89 04 24             	mov    %eax,(%esp)
801051f5:	e8 db 39 00 00       	call   80108bd5 <freevm>
        p->state = UNUSED;
801051fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80105204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105207:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010520e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105211:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010521b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010521f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105222:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
	if(retime!=0 && rutime!=0 && stime!=0){
80105229:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010522d:	74 36                	je     80105265 <wait2+0xea>
8010522f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105233:	74 30                	je     80105265 <wait2+0xea>
80105235:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105239:	74 2a                	je     80105265 <wait2+0xea>
	  *retime=p->retime;
8010523b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010523e:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80105244:	8b 45 08             	mov    0x8(%ebp),%eax
80105247:	89 10                	mov    %edx,(%eax)
	  *rutime=p->rutime;
80105249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524c:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80105252:	8b 45 0c             	mov    0xc(%ebp),%eax
80105255:	89 10                	mov    %edx,(%eax)
	  *stime=p->stime; 
80105257:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010525a:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80105260:	8b 45 10             	mov    0x10(%ebp),%eax
80105263:	89 10                	mov    %edx,(%eax)
	}
        release(&ptable.lock);
80105265:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010526c:	e8 cb 05 00 00       	call   8010583c <release>
        return pid;
80105271:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105274:	eb 55                	jmp    801052cb <wait2+0x150>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105276:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
8010527d:	81 7d f4 b4 64 11 80 	cmpl   $0x801164b4,-0xc(%ebp)
80105284:	0f 82 16 ff ff ff    	jb     801051a0 <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
8010528a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010528e:	74 0d                	je     8010529d <wait2+0x122>
80105290:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105296:	8b 40 24             	mov    0x24(%eax),%eax
80105299:	85 c0                	test   %eax,%eax
8010529b:	74 13                	je     801052b0 <wait2+0x135>
      release(&ptable.lock);
8010529d:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
801052a4:	e8 93 05 00 00       	call   8010583c <release>
      return -1;
801052a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ae:	eb 1b                	jmp    801052cb <wait2+0x150>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801052b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052b6:	c7 44 24 04 80 41 11 	movl   $0x80114180,0x4(%esp)
801052bd:	80 
801052be:	89 04 24             	mov    %eax,(%esp)
801052c1:	e8 c5 01 00 00       	call   8010548b <sleep>
  }
801052c6:	e9 c2 fe ff ff       	jmp    8010518d <wait2+0x12>
}
801052cb:	c9                   	leave  
801052cc:	c3                   	ret    

801052cd <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801052cd:	55                   	push   %ebp
801052ce:	89 e5                	mov    %esp,%ebp
801052d0:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801052d3:	e8 fb f7 ff ff       	call   80104ad3 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801052d8:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
801052df:	e8 f6 04 00 00       	call   801057da <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052e4:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
801052eb:	eb 61                	jmp    8010534e <scheduler+0x81>
      if(p->state != RUNNABLE)
801052ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f0:	8b 40 0c             	mov    0xc(%eax),%eax
801052f3:	83 f8 03             	cmp    $0x3,%eax
801052f6:	74 02                	je     801052fa <scheduler+0x2d>
        continue;
801052f8:	eb 4d                	jmp    80105347 <scheduler+0x7a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801052fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052fd:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80105303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105306:	89 04 24             	mov    %eax,(%esp)
80105309:	e8 54 34 00 00       	call   80108762 <switchuvm>
      p->state = RUNNING;
8010530e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105311:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105318:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010531e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105321:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105328:	83 c2 04             	add    $0x4,%edx
8010532b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010532f:	89 14 24             	mov    %edx,(%esp)
80105332:	e8 88 09 00 00       	call   80105cbf <swtch>
      switchkvm();
80105337:	e8 09 34 00 00       	call   80108745 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010533c:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105343:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105347:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
8010534e:	81 7d f4 b4 64 11 80 	cmpl   $0x801164b4,-0xc(%ebp)
80105355:	72 96                	jb     801052ed <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105357:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010535e:	e8 d9 04 00 00       	call   8010583c <release>

  }
80105363:	e9 6b ff ff ff       	jmp    801052d3 <scheduler+0x6>

80105368 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105368:	55                   	push   %ebp
80105369:	89 e5                	mov    %esp,%ebp
8010536b:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
8010536e:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105375:	e8 8a 05 00 00       	call   80105904 <holding>
8010537a:	85 c0                	test   %eax,%eax
8010537c:	75 0c                	jne    8010538a <sched+0x22>
    panic("sched ptable.lock");
8010537e:	c7 04 24 6d 92 10 80 	movl   $0x8010926d,(%esp)
80105385:	e8 b0 b1 ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
8010538a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105390:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105396:	83 f8 01             	cmp    $0x1,%eax
80105399:	74 0c                	je     801053a7 <sched+0x3f>
    panic("sched locks");
8010539b:	c7 04 24 7f 92 10 80 	movl   $0x8010927f,(%esp)
801053a2:	e8 93 b1 ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
801053a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ad:	8b 40 0c             	mov    0xc(%eax),%eax
801053b0:	83 f8 04             	cmp    $0x4,%eax
801053b3:	75 0c                	jne    801053c1 <sched+0x59>
    panic("sched running");
801053b5:	c7 04 24 8b 92 10 80 	movl   $0x8010928b,(%esp)
801053bc:	e8 79 b1 ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
801053c1:	e8 fd f6 ff ff       	call   80104ac3 <readeflags>
801053c6:	25 00 02 00 00       	and    $0x200,%eax
801053cb:	85 c0                	test   %eax,%eax
801053cd:	74 0c                	je     801053db <sched+0x73>
    panic("sched interruptible");
801053cf:	c7 04 24 99 92 10 80 	movl   $0x80109299,(%esp)
801053d6:	e8 5f b1 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
801053db:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053e1:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801053e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801053ea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053f0:	8b 40 04             	mov    0x4(%eax),%eax
801053f3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801053fa:	83 c2 1c             	add    $0x1c,%edx
801053fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105401:	89 14 24             	mov    %edx,(%esp)
80105404:	e8 b6 08 00 00       	call   80105cbf <swtch>
  cpu->intena = intena;
80105409:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010540f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105412:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105418:	c9                   	leave  
80105419:	c3                   	ret    

8010541a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010541a:	55                   	push   %ebp
8010541b:	89 e5                	mov    %esp,%ebp
8010541d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105420:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105427:	e8 ae 03 00 00       	call   801057da <acquire>
  proc->state = RUNNABLE;
8010542c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105432:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105439:	e8 2a ff ff ff       	call   80105368 <sched>
  release(&ptable.lock);
8010543e:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105445:	e8 f2 03 00 00       	call   8010583c <release>
}
8010544a:	c9                   	leave  
8010544b:	c3                   	ret    

8010544c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010544c:	55                   	push   %ebp
8010544d:	89 e5                	mov    %esp,%ebp
8010544f:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105452:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105459:	e8 de 03 00 00       	call   8010583c <release>

  if (first) {
8010545e:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80105463:	85 c0                	test   %eax,%eax
80105465:	74 22                	je     80105489 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105467:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
8010546e:	00 00 00 
    iinit(ROOTDEV);
80105471:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105478:	e8 75 c8 ff ff       	call   80101cf2 <iinit>
    initlog(ROOTDEV);
8010547d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105484:	e8 75 e5 ff ff       	call   801039fe <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80105489:	c9                   	leave  
8010548a:	c3                   	ret    

8010548b <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010548b:	55                   	push   %ebp
8010548c:	89 e5                	mov    %esp,%ebp
8010548e:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80105491:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105497:	85 c0                	test   %eax,%eax
80105499:	75 0c                	jne    801054a7 <sleep+0x1c>
    panic("sleep");
8010549b:	c7 04 24 ad 92 10 80 	movl   $0x801092ad,(%esp)
801054a2:	e8 93 b0 ff ff       	call   8010053a <panic>

  if(lk == 0)
801054a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801054ab:	75 0c                	jne    801054b9 <sleep+0x2e>
    panic("sleep without lk");
801054ad:	c7 04 24 b3 92 10 80 	movl   $0x801092b3,(%esp)
801054b4:	e8 81 b0 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801054b9:	81 7d 0c 80 41 11 80 	cmpl   $0x80114180,0xc(%ebp)
801054c0:	74 17                	je     801054d9 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
801054c2:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
801054c9:	e8 0c 03 00 00       	call   801057da <acquire>
    release(lk);
801054ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801054d1:	89 04 24             	mov    %eax,(%esp)
801054d4:	e8 63 03 00 00       	call   8010583c <release>
  }

  // Go to sleep.
  proc->chan = chan;
801054d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054df:	8b 55 08             	mov    0x8(%ebp),%edx
801054e2:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801054e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054eb:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801054f2:	e8 71 fe ff ff       	call   80105368 <sched>

  // Tidy up.
  proc->chan = 0;
801054f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054fd:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105504:	81 7d 0c 80 41 11 80 	cmpl   $0x80114180,0xc(%ebp)
8010550b:	74 17                	je     80105524 <sleep+0x99>
    release(&ptable.lock);
8010550d:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105514:	e8 23 03 00 00       	call   8010583c <release>
    acquire(lk);
80105519:	8b 45 0c             	mov    0xc(%ebp),%eax
8010551c:	89 04 24             	mov    %eax,(%esp)
8010551f:	e8 b6 02 00 00       	call   801057da <acquire>
  }
}
80105524:	c9                   	leave  
80105525:	c3                   	ret    

80105526 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80105526:	55                   	push   %ebp
80105527:	89 e5                	mov    %esp,%ebp
80105529:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010552c:	c7 45 fc b4 41 11 80 	movl   $0x801141b4,-0x4(%ebp)
80105533:	eb 27                	jmp    8010555c <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80105535:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105538:	8b 40 0c             	mov    0xc(%eax),%eax
8010553b:	83 f8 02             	cmp    $0x2,%eax
8010553e:	75 15                	jne    80105555 <wakeup1+0x2f>
80105540:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105543:	8b 40 20             	mov    0x20(%eax),%eax
80105546:	3b 45 08             	cmp    0x8(%ebp),%eax
80105549:	75 0a                	jne    80105555 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010554b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010554e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105555:	81 45 fc 8c 00 00 00 	addl   $0x8c,-0x4(%ebp)
8010555c:	81 7d fc b4 64 11 80 	cmpl   $0x801164b4,-0x4(%ebp)
80105563:	72 d0                	jb     80105535 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105565:	c9                   	leave  
80105566:	c3                   	ret    

80105567 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105567:	55                   	push   %ebp
80105568:	89 e5                	mov    %esp,%ebp
8010556a:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
8010556d:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105574:	e8 61 02 00 00       	call   801057da <acquire>
  wakeup1(chan);
80105579:	8b 45 08             	mov    0x8(%ebp),%eax
8010557c:	89 04 24             	mov    %eax,(%esp)
8010557f:	e8 a2 ff ff ff       	call   80105526 <wakeup1>
  release(&ptable.lock);
80105584:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010558b:	e8 ac 02 00 00       	call   8010583c <release>
}
80105590:	c9                   	leave  
80105591:	c3                   	ret    

80105592 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105592:	55                   	push   %ebp
80105593:	89 e5                	mov    %esp,%ebp
80105595:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105598:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
8010559f:	e8 36 02 00 00       	call   801057da <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055a4:	c7 45 f4 b4 41 11 80 	movl   $0x801141b4,-0xc(%ebp)
801055ab:	eb 44                	jmp    801055f1 <kill+0x5f>
    if(p->pid == pid){
801055ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b0:	8b 40 10             	mov    0x10(%eax),%eax
801055b3:	3b 45 08             	cmp    0x8(%ebp),%eax
801055b6:	75 32                	jne    801055ea <kill+0x58>
      p->killed = 1;
801055b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801055c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c5:	8b 40 0c             	mov    0xc(%eax),%eax
801055c8:	83 f8 02             	cmp    $0x2,%eax
801055cb:	75 0a                	jne    801055d7 <kill+0x45>
        p->state = RUNNABLE;
801055cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801055d7:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
801055de:	e8 59 02 00 00       	call   8010583c <release>
      return 0;
801055e3:	b8 00 00 00 00       	mov    $0x0,%eax
801055e8:	eb 21                	jmp    8010560b <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801055ea:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
801055f1:	81 7d f4 b4 64 11 80 	cmpl   $0x801164b4,-0xc(%ebp)
801055f8:	72 b3                	jb     801055ad <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801055fa:	c7 04 24 80 41 11 80 	movl   $0x80114180,(%esp)
80105601:	e8 36 02 00 00       	call   8010583c <release>
  return -1;
80105606:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010560b:	c9                   	leave  
8010560c:	c3                   	ret    

8010560d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010560d:	55                   	push   %ebp
8010560e:	89 e5                	mov    %esp,%ebp
80105610:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105613:	c7 45 f0 b4 41 11 80 	movl   $0x801141b4,-0x10(%ebp)
8010561a:	e9 d9 00 00 00       	jmp    801056f8 <procdump+0xeb>
    if(p->state == UNUSED)
8010561f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105622:	8b 40 0c             	mov    0xc(%eax),%eax
80105625:	85 c0                	test   %eax,%eax
80105627:	75 05                	jne    8010562e <procdump+0x21>
      continue;
80105629:	e9 c3 00 00 00       	jmp    801056f1 <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010562e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105631:	8b 40 0c             	mov    0xc(%eax),%eax
80105634:	83 f8 05             	cmp    $0x5,%eax
80105637:	77 23                	ja     8010565c <procdump+0x4f>
80105639:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010563c:	8b 40 0c             	mov    0xc(%eax),%eax
8010563f:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105646:	85 c0                	test   %eax,%eax
80105648:	74 12                	je     8010565c <procdump+0x4f>
      state = states[p->state];
8010564a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010564d:	8b 40 0c             	mov    0xc(%eax),%eax
80105650:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105657:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010565a:	eb 07                	jmp    80105663 <procdump+0x56>
    else
      state = "???";
8010565c:	c7 45 ec c4 92 10 80 	movl   $0x801092c4,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105663:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105666:	8d 50 6c             	lea    0x6c(%eax),%edx
80105669:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010566c:	8b 40 10             	mov    0x10(%eax),%eax
8010566f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105673:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105676:	89 54 24 08          	mov    %edx,0x8(%esp)
8010567a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010567e:	c7 04 24 c8 92 10 80 	movl   $0x801092c8,(%esp)
80105685:	e8 16 ad ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
8010568a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010568d:	8b 40 0c             	mov    0xc(%eax),%eax
80105690:	83 f8 02             	cmp    $0x2,%eax
80105693:	75 50                	jne    801056e5 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105695:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105698:	8b 40 1c             	mov    0x1c(%eax),%eax
8010569b:	8b 40 0c             	mov    0xc(%eax),%eax
8010569e:	83 c0 08             	add    $0x8,%eax
801056a1:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801056a4:	89 54 24 04          	mov    %edx,0x4(%esp)
801056a8:	89 04 24             	mov    %eax,(%esp)
801056ab:	e8 db 01 00 00       	call   8010588b <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801056b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801056b7:	eb 1b                	jmp    801056d4 <procdump+0xc7>
        cprintf(" %p", pc[i]);
801056b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056bc:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801056c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801056c4:	c7 04 24 d1 92 10 80 	movl   $0x801092d1,(%esp)
801056cb:	e8 d0 ac ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801056d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801056d4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801056d8:	7f 0b                	jg     801056e5 <procdump+0xd8>
801056da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056dd:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801056e1:	85 c0                	test   %eax,%eax
801056e3:	75 d4                	jne    801056b9 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801056e5:	c7 04 24 d5 92 10 80 	movl   $0x801092d5,(%esp)
801056ec:	e8 af ac ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056f1:	81 45 f0 8c 00 00 00 	addl   $0x8c,-0x10(%ebp)
801056f8:	81 7d f0 b4 64 11 80 	cmpl   $0x801164b4,-0x10(%ebp)
801056ff:	0f 82 1a ff ff ff    	jb     8010561f <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105705:	c9                   	leave  
80105706:	c3                   	ret    

80105707 <update_statistics>:


void
update_statistics(void){
80105707:	55                   	push   %ebp
80105708:	89 e5                	mov    %esp,%ebp
8010570a:	83 ec 10             	sub    $0x10,%esp
    
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010570d:	c7 45 fc b4 41 11 80 	movl   $0x801141b4,-0x4(%ebp)
80105714:	eb 62                	jmp    80105778 <update_statistics+0x71>
    switch(p->state){
80105716:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105719:	8b 40 0c             	mov    0xc(%eax),%eax
8010571c:	83 f8 03             	cmp    $0x3,%eax
8010571f:	74 23                	je     80105744 <update_statistics+0x3d>
80105721:	83 f8 04             	cmp    $0x4,%eax
80105724:	74 07                	je     8010572d <update_statistics+0x26>
80105726:	83 f8 02             	cmp    $0x2,%eax
80105729:	74 30                	je     8010575b <update_statistics+0x54>
	continue;
      case SLEEPING:
	p->stime++;
	continue;
      default: 
	continue;
8010572b:	eb 44                	jmp    80105771 <update_statistics+0x6a>
    
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    switch(p->state){
      case RUNNING: 
	p->rutime++; 
8010572d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105730:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105736:	8d 50 01             	lea    0x1(%eax),%edx
80105739:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010573c:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
	continue;
80105742:	eb 2d                	jmp    80105771 <update_statistics+0x6a>
      case RUNNABLE: 
	p->retime++;
80105744:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105747:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010574d:	8d 50 01             	lea    0x1(%eax),%edx
80105750:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105753:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
	continue;
80105759:	eb 16                	jmp    80105771 <update_statistics+0x6a>
      case SLEEPING:
	p->stime++;
8010575b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010575e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105764:	8d 50 01             	lea    0x1(%eax),%edx
80105767:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010576a:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
	continue;
80105770:	90                   	nop

void
update_statistics(void){
    
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105771:	81 45 fc 8c 00 00 00 	addl   $0x8c,-0x4(%ebp)
80105778:	81 7d fc b4 64 11 80 	cmpl   $0x801164b4,-0x4(%ebp)
8010577f:	72 95                	jb     80105716 <update_statistics+0xf>
	continue;
      default: 
	continue;
    }   
  }
80105781:	c9                   	leave  
80105782:	c3                   	ret    

80105783 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105783:	55                   	push   %ebp
80105784:	89 e5                	mov    %esp,%ebp
80105786:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105789:	9c                   	pushf  
8010578a:	58                   	pop    %eax
8010578b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010578e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105791:	c9                   	leave  
80105792:	c3                   	ret    

80105793 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105793:	55                   	push   %ebp
80105794:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105796:	fa                   	cli    
}
80105797:	5d                   	pop    %ebp
80105798:	c3                   	ret    

80105799 <sti>:

static inline void
sti(void)
{
80105799:	55                   	push   %ebp
8010579a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010579c:	fb                   	sti    
}
8010579d:	5d                   	pop    %ebp
8010579e:	c3                   	ret    

8010579f <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010579f:	55                   	push   %ebp
801057a0:	89 e5                	mov    %esp,%ebp
801057a2:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801057a5:	8b 55 08             	mov    0x8(%ebp),%edx
801057a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
801057ae:	f0 87 02             	lock xchg %eax,(%edx)
801057b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801057b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057b7:	c9                   	leave  
801057b8:	c3                   	ret    

801057b9 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801057b9:	55                   	push   %ebp
801057ba:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801057bc:	8b 45 08             	mov    0x8(%ebp),%eax
801057bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801057c2:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801057c5:	8b 45 08             	mov    0x8(%ebp),%eax
801057c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801057ce:	8b 45 08             	mov    0x8(%ebp),%eax
801057d1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801057d8:	5d                   	pop    %ebp
801057d9:	c3                   	ret    

801057da <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801057da:	55                   	push   %ebp
801057db:	89 e5                	mov    %esp,%ebp
801057dd:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801057e0:	e8 49 01 00 00       	call   8010592e <pushcli>
  if(holding(lk))
801057e5:	8b 45 08             	mov    0x8(%ebp),%eax
801057e8:	89 04 24             	mov    %eax,(%esp)
801057eb:	e8 14 01 00 00       	call   80105904 <holding>
801057f0:	85 c0                	test   %eax,%eax
801057f2:	74 0c                	je     80105800 <acquire+0x26>
    panic("acquire");
801057f4:	c7 04 24 01 93 10 80 	movl   $0x80109301,(%esp)
801057fb:	e8 3a ad ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105800:	90                   	nop
80105801:	8b 45 08             	mov    0x8(%ebp),%eax
80105804:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010580b:	00 
8010580c:	89 04 24             	mov    %eax,(%esp)
8010580f:	e8 8b ff ff ff       	call   8010579f <xchg>
80105814:	85 c0                	test   %eax,%eax
80105816:	75 e9                	jne    80105801 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105818:	8b 45 08             	mov    0x8(%ebp),%eax
8010581b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105822:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105825:	8b 45 08             	mov    0x8(%ebp),%eax
80105828:	83 c0 0c             	add    $0xc,%eax
8010582b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010582f:	8d 45 08             	lea    0x8(%ebp),%eax
80105832:	89 04 24             	mov    %eax,(%esp)
80105835:	e8 51 00 00 00       	call   8010588b <getcallerpcs>
}
8010583a:	c9                   	leave  
8010583b:	c3                   	ret    

8010583c <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010583c:	55                   	push   %ebp
8010583d:	89 e5                	mov    %esp,%ebp
8010583f:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105842:	8b 45 08             	mov    0x8(%ebp),%eax
80105845:	89 04 24             	mov    %eax,(%esp)
80105848:	e8 b7 00 00 00       	call   80105904 <holding>
8010584d:	85 c0                	test   %eax,%eax
8010584f:	75 0c                	jne    8010585d <release+0x21>
    panic("release");
80105851:	c7 04 24 09 93 10 80 	movl   $0x80109309,(%esp)
80105858:	e8 dd ac ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
8010585d:	8b 45 08             	mov    0x8(%ebp),%eax
80105860:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105867:	8b 45 08             	mov    0x8(%ebp),%eax
8010586a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105871:	8b 45 08             	mov    0x8(%ebp),%eax
80105874:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010587b:	00 
8010587c:	89 04 24             	mov    %eax,(%esp)
8010587f:	e8 1b ff ff ff       	call   8010579f <xchg>

  popcli();
80105884:	e8 e9 00 00 00       	call   80105972 <popcli>
}
80105889:	c9                   	leave  
8010588a:	c3                   	ret    

8010588b <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010588b:	55                   	push   %ebp
8010588c:	89 e5                	mov    %esp,%ebp
8010588e:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105891:	8b 45 08             	mov    0x8(%ebp),%eax
80105894:	83 e8 08             	sub    $0x8,%eax
80105897:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010589a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801058a1:	eb 38                	jmp    801058db <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801058a3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801058a7:	74 38                	je     801058e1 <getcallerpcs+0x56>
801058a9:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801058b0:	76 2f                	jbe    801058e1 <getcallerpcs+0x56>
801058b2:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801058b6:	74 29                	je     801058e1 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
801058b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058bb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801058c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801058c5:	01 c2                	add    %eax,%edx
801058c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058ca:	8b 40 04             	mov    0x4(%eax),%eax
801058cd:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801058cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058d2:	8b 00                	mov    (%eax),%eax
801058d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801058d7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801058db:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801058df:	7e c2                	jle    801058a3 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801058e1:	eb 19                	jmp    801058fc <getcallerpcs+0x71>
    pcs[i] = 0;
801058e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058e6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801058ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f0:	01 d0                	add    %edx,%eax
801058f2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801058f8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801058fc:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105900:	7e e1                	jle    801058e3 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105902:	c9                   	leave  
80105903:	c3                   	ret    

80105904 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105904:	55                   	push   %ebp
80105905:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105907:	8b 45 08             	mov    0x8(%ebp),%eax
8010590a:	8b 00                	mov    (%eax),%eax
8010590c:	85 c0                	test   %eax,%eax
8010590e:	74 17                	je     80105927 <holding+0x23>
80105910:	8b 45 08             	mov    0x8(%ebp),%eax
80105913:	8b 50 08             	mov    0x8(%eax),%edx
80105916:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010591c:	39 c2                	cmp    %eax,%edx
8010591e:	75 07                	jne    80105927 <holding+0x23>
80105920:	b8 01 00 00 00       	mov    $0x1,%eax
80105925:	eb 05                	jmp    8010592c <holding+0x28>
80105927:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010592c:	5d                   	pop    %ebp
8010592d:	c3                   	ret    

8010592e <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010592e:	55                   	push   %ebp
8010592f:	89 e5                	mov    %esp,%ebp
80105931:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105934:	e8 4a fe ff ff       	call   80105783 <readeflags>
80105939:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010593c:	e8 52 fe ff ff       	call   80105793 <cli>
  if(cpu->ncli++ == 0)
80105941:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105948:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
8010594e:	8d 48 01             	lea    0x1(%eax),%ecx
80105951:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105957:	85 c0                	test   %eax,%eax
80105959:	75 15                	jne    80105970 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010595b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105961:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105964:	81 e2 00 02 00 00    	and    $0x200,%edx
8010596a:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105970:	c9                   	leave  
80105971:	c3                   	ret    

80105972 <popcli>:

void
popcli(void)
{
80105972:	55                   	push   %ebp
80105973:	89 e5                	mov    %esp,%ebp
80105975:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105978:	e8 06 fe ff ff       	call   80105783 <readeflags>
8010597d:	25 00 02 00 00       	and    $0x200,%eax
80105982:	85 c0                	test   %eax,%eax
80105984:	74 0c                	je     80105992 <popcli+0x20>
    panic("popcli - interruptible");
80105986:	c7 04 24 11 93 10 80 	movl   $0x80109311,(%esp)
8010598d:	e8 a8 ab ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105992:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105998:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010599e:	83 ea 01             	sub    $0x1,%edx
801059a1:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801059a7:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801059ad:	85 c0                	test   %eax,%eax
801059af:	79 0c                	jns    801059bd <popcli+0x4b>
    panic("popcli");
801059b1:	c7 04 24 28 93 10 80 	movl   $0x80109328,(%esp)
801059b8:	e8 7d ab ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
801059bd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801059c3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801059c9:	85 c0                	test   %eax,%eax
801059cb:	75 15                	jne    801059e2 <popcli+0x70>
801059cd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801059d3:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801059d9:	85 c0                	test   %eax,%eax
801059db:	74 05                	je     801059e2 <popcli+0x70>
    sti();
801059dd:	e8 b7 fd ff ff       	call   80105799 <sti>
}
801059e2:	c9                   	leave  
801059e3:	c3                   	ret    

801059e4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801059e4:	55                   	push   %ebp
801059e5:	89 e5                	mov    %esp,%ebp
801059e7:	57                   	push   %edi
801059e8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801059e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801059ec:	8b 55 10             	mov    0x10(%ebp),%edx
801059ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801059f2:	89 cb                	mov    %ecx,%ebx
801059f4:	89 df                	mov    %ebx,%edi
801059f6:	89 d1                	mov    %edx,%ecx
801059f8:	fc                   	cld    
801059f9:	f3 aa                	rep stos %al,%es:(%edi)
801059fb:	89 ca                	mov    %ecx,%edx
801059fd:	89 fb                	mov    %edi,%ebx
801059ff:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105a02:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105a05:	5b                   	pop    %ebx
80105a06:	5f                   	pop    %edi
80105a07:	5d                   	pop    %ebp
80105a08:	c3                   	ret    

80105a09 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105a09:	55                   	push   %ebp
80105a0a:	89 e5                	mov    %esp,%ebp
80105a0c:	57                   	push   %edi
80105a0d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105a0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105a11:	8b 55 10             	mov    0x10(%ebp),%edx
80105a14:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a17:	89 cb                	mov    %ecx,%ebx
80105a19:	89 df                	mov    %ebx,%edi
80105a1b:	89 d1                	mov    %edx,%ecx
80105a1d:	fc                   	cld    
80105a1e:	f3 ab                	rep stos %eax,%es:(%edi)
80105a20:	89 ca                	mov    %ecx,%edx
80105a22:	89 fb                	mov    %edi,%ebx
80105a24:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105a27:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105a2a:	5b                   	pop    %ebx
80105a2b:	5f                   	pop    %edi
80105a2c:	5d                   	pop    %ebp
80105a2d:	c3                   	ret    

80105a2e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105a2e:	55                   	push   %ebp
80105a2f:	89 e5                	mov    %esp,%ebp
80105a31:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105a34:	8b 45 08             	mov    0x8(%ebp),%eax
80105a37:	83 e0 03             	and    $0x3,%eax
80105a3a:	85 c0                	test   %eax,%eax
80105a3c:	75 49                	jne    80105a87 <memset+0x59>
80105a3e:	8b 45 10             	mov    0x10(%ebp),%eax
80105a41:	83 e0 03             	and    $0x3,%eax
80105a44:	85 c0                	test   %eax,%eax
80105a46:	75 3f                	jne    80105a87 <memset+0x59>
    c &= 0xFF;
80105a48:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105a4f:	8b 45 10             	mov    0x10(%ebp),%eax
80105a52:	c1 e8 02             	shr    $0x2,%eax
80105a55:	89 c2                	mov    %eax,%edx
80105a57:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a5a:	c1 e0 18             	shl    $0x18,%eax
80105a5d:	89 c1                	mov    %eax,%ecx
80105a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a62:	c1 e0 10             	shl    $0x10,%eax
80105a65:	09 c1                	or     %eax,%ecx
80105a67:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a6a:	c1 e0 08             	shl    $0x8,%eax
80105a6d:	09 c8                	or     %ecx,%eax
80105a6f:	0b 45 0c             	or     0xc(%ebp),%eax
80105a72:	89 54 24 08          	mov    %edx,0x8(%esp)
80105a76:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80105a7d:	89 04 24             	mov    %eax,(%esp)
80105a80:	e8 84 ff ff ff       	call   80105a09 <stosl>
80105a85:	eb 19                	jmp    80105aa0 <memset+0x72>
  } else
    stosb(dst, c, n);
80105a87:	8b 45 10             	mov    0x10(%ebp),%eax
80105a8a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a91:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a95:	8b 45 08             	mov    0x8(%ebp),%eax
80105a98:	89 04 24             	mov    %eax,(%esp)
80105a9b:	e8 44 ff ff ff       	call   801059e4 <stosb>
  return dst;
80105aa0:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105aa3:	c9                   	leave  
80105aa4:	c3                   	ret    

80105aa5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105aa5:	55                   	push   %ebp
80105aa6:	89 e5                	mov    %esp,%ebp
80105aa8:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105aab:	8b 45 08             	mov    0x8(%ebp),%eax
80105aae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ab4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105ab7:	eb 30                	jmp    80105ae9 <memcmp+0x44>
    if(*s1 != *s2)
80105ab9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105abc:	0f b6 10             	movzbl (%eax),%edx
80105abf:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ac2:	0f b6 00             	movzbl (%eax),%eax
80105ac5:	38 c2                	cmp    %al,%dl
80105ac7:	74 18                	je     80105ae1 <memcmp+0x3c>
      return *s1 - *s2;
80105ac9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105acc:	0f b6 00             	movzbl (%eax),%eax
80105acf:	0f b6 d0             	movzbl %al,%edx
80105ad2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ad5:	0f b6 00             	movzbl (%eax),%eax
80105ad8:	0f b6 c0             	movzbl %al,%eax
80105adb:	29 c2                	sub    %eax,%edx
80105add:	89 d0                	mov    %edx,%eax
80105adf:	eb 1a                	jmp    80105afb <memcmp+0x56>
    s1++, s2++;
80105ae1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105ae5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105ae9:	8b 45 10             	mov    0x10(%ebp),%eax
80105aec:	8d 50 ff             	lea    -0x1(%eax),%edx
80105aef:	89 55 10             	mov    %edx,0x10(%ebp)
80105af2:	85 c0                	test   %eax,%eax
80105af4:	75 c3                	jne    80105ab9 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105af6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105afb:	c9                   	leave  
80105afc:	c3                   	ret    

80105afd <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105afd:	55                   	push   %ebp
80105afe:	89 e5                	mov    %esp,%ebp
80105b00:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105b03:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b06:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105b09:	8b 45 08             	mov    0x8(%ebp),%eax
80105b0c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105b0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b12:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105b15:	73 3d                	jae    80105b54 <memmove+0x57>
80105b17:	8b 45 10             	mov    0x10(%ebp),%eax
80105b1a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b1d:	01 d0                	add    %edx,%eax
80105b1f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105b22:	76 30                	jbe    80105b54 <memmove+0x57>
    s += n;
80105b24:	8b 45 10             	mov    0x10(%ebp),%eax
80105b27:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105b2a:	8b 45 10             	mov    0x10(%ebp),%eax
80105b2d:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105b30:	eb 13                	jmp    80105b45 <memmove+0x48>
      *--d = *--s;
80105b32:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105b36:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105b3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b3d:	0f b6 10             	movzbl (%eax),%edx
80105b40:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b43:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105b45:	8b 45 10             	mov    0x10(%ebp),%eax
80105b48:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b4b:	89 55 10             	mov    %edx,0x10(%ebp)
80105b4e:	85 c0                	test   %eax,%eax
80105b50:	75 e0                	jne    80105b32 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105b52:	eb 26                	jmp    80105b7a <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105b54:	eb 17                	jmp    80105b6d <memmove+0x70>
      *d++ = *s++;
80105b56:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b59:	8d 50 01             	lea    0x1(%eax),%edx
80105b5c:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105b5f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b62:	8d 4a 01             	lea    0x1(%edx),%ecx
80105b65:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105b68:	0f b6 12             	movzbl (%edx),%edx
80105b6b:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105b6d:	8b 45 10             	mov    0x10(%ebp),%eax
80105b70:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b73:	89 55 10             	mov    %edx,0x10(%ebp)
80105b76:	85 c0                	test   %eax,%eax
80105b78:	75 dc                	jne    80105b56 <memmove+0x59>
      *d++ = *s++;

  return dst;
80105b7a:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105b7d:	c9                   	leave  
80105b7e:	c3                   	ret    

80105b7f <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105b7f:	55                   	push   %ebp
80105b80:	89 e5                	mov    %esp,%ebp
80105b82:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105b85:	8b 45 10             	mov    0x10(%ebp),%eax
80105b88:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b93:	8b 45 08             	mov    0x8(%ebp),%eax
80105b96:	89 04 24             	mov    %eax,(%esp)
80105b99:	e8 5f ff ff ff       	call   80105afd <memmove>
}
80105b9e:	c9                   	leave  
80105b9f:	c3                   	ret    

80105ba0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105ba0:	55                   	push   %ebp
80105ba1:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105ba3:	eb 0c                	jmp    80105bb1 <strncmp+0x11>
    n--, p++, q++;
80105ba5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105ba9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105bad:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105bb1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105bb5:	74 1a                	je     80105bd1 <strncmp+0x31>
80105bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80105bba:	0f b6 00             	movzbl (%eax),%eax
80105bbd:	84 c0                	test   %al,%al
80105bbf:	74 10                	je     80105bd1 <strncmp+0x31>
80105bc1:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc4:	0f b6 10             	movzbl (%eax),%edx
80105bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bca:	0f b6 00             	movzbl (%eax),%eax
80105bcd:	38 c2                	cmp    %al,%dl
80105bcf:	74 d4                	je     80105ba5 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105bd1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105bd5:	75 07                	jne    80105bde <strncmp+0x3e>
    return 0;
80105bd7:	b8 00 00 00 00       	mov    $0x0,%eax
80105bdc:	eb 16                	jmp    80105bf4 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105bde:	8b 45 08             	mov    0x8(%ebp),%eax
80105be1:	0f b6 00             	movzbl (%eax),%eax
80105be4:	0f b6 d0             	movzbl %al,%edx
80105be7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bea:	0f b6 00             	movzbl (%eax),%eax
80105bed:	0f b6 c0             	movzbl %al,%eax
80105bf0:	29 c2                	sub    %eax,%edx
80105bf2:	89 d0                	mov    %edx,%eax
}
80105bf4:	5d                   	pop    %ebp
80105bf5:	c3                   	ret    

80105bf6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105bf6:	55                   	push   %ebp
80105bf7:	89 e5                	mov    %esp,%ebp
80105bf9:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80105bff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105c02:	90                   	nop
80105c03:	8b 45 10             	mov    0x10(%ebp),%eax
80105c06:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c09:	89 55 10             	mov    %edx,0x10(%ebp)
80105c0c:	85 c0                	test   %eax,%eax
80105c0e:	7e 1e                	jle    80105c2e <strncpy+0x38>
80105c10:	8b 45 08             	mov    0x8(%ebp),%eax
80105c13:	8d 50 01             	lea    0x1(%eax),%edx
80105c16:	89 55 08             	mov    %edx,0x8(%ebp)
80105c19:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c1c:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c1f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105c22:	0f b6 12             	movzbl (%edx),%edx
80105c25:	88 10                	mov    %dl,(%eax)
80105c27:	0f b6 00             	movzbl (%eax),%eax
80105c2a:	84 c0                	test   %al,%al
80105c2c:	75 d5                	jne    80105c03 <strncpy+0xd>
    ;
  while(n-- > 0)
80105c2e:	eb 0c                	jmp    80105c3c <strncpy+0x46>
    *s++ = 0;
80105c30:	8b 45 08             	mov    0x8(%ebp),%eax
80105c33:	8d 50 01             	lea    0x1(%eax),%edx
80105c36:	89 55 08             	mov    %edx,0x8(%ebp)
80105c39:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105c3c:	8b 45 10             	mov    0x10(%ebp),%eax
80105c3f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c42:	89 55 10             	mov    %edx,0x10(%ebp)
80105c45:	85 c0                	test   %eax,%eax
80105c47:	7f e7                	jg     80105c30 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105c49:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c4c:	c9                   	leave  
80105c4d:	c3                   	ret    

80105c4e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105c4e:	55                   	push   %ebp
80105c4f:	89 e5                	mov    %esp,%ebp
80105c51:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105c54:	8b 45 08             	mov    0x8(%ebp),%eax
80105c57:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105c5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c5e:	7f 05                	jg     80105c65 <safestrcpy+0x17>
    return os;
80105c60:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c63:	eb 31                	jmp    80105c96 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105c65:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105c69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c6d:	7e 1e                	jle    80105c8d <safestrcpy+0x3f>
80105c6f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c72:	8d 50 01             	lea    0x1(%eax),%edx
80105c75:	89 55 08             	mov    %edx,0x8(%ebp)
80105c78:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c7b:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c7e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105c81:	0f b6 12             	movzbl (%edx),%edx
80105c84:	88 10                	mov    %dl,(%eax)
80105c86:	0f b6 00             	movzbl (%eax),%eax
80105c89:	84 c0                	test   %al,%al
80105c8b:	75 d8                	jne    80105c65 <safestrcpy+0x17>
    ;
  *s = 0;
80105c8d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c90:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105c93:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c96:	c9                   	leave  
80105c97:	c3                   	ret    

80105c98 <strlen>:

int
strlen(const char *s)
{
80105c98:	55                   	push   %ebp
80105c99:	89 e5                	mov    %esp,%ebp
80105c9b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105c9e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105ca5:	eb 04                	jmp    80105cab <strlen+0x13>
80105ca7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105cab:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105cae:	8b 45 08             	mov    0x8(%ebp),%eax
80105cb1:	01 d0                	add    %edx,%eax
80105cb3:	0f b6 00             	movzbl (%eax),%eax
80105cb6:	84 c0                	test   %al,%al
80105cb8:	75 ed                	jne    80105ca7 <strlen+0xf>
    ;
  return n;
80105cba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105cbd:	c9                   	leave  
80105cbe:	c3                   	ret    

80105cbf <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105cbf:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105cc3:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105cc7:	55                   	push   %ebp
  pushl %ebx
80105cc8:	53                   	push   %ebx
  pushl %esi
80105cc9:	56                   	push   %esi
  pushl %edi
80105cca:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105ccb:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105ccd:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105ccf:	5f                   	pop    %edi
  popl %esi
80105cd0:	5e                   	pop    %esi
  popl %ebx
80105cd1:	5b                   	pop    %ebx
  popl %ebp
80105cd2:	5d                   	pop    %ebp
  ret
80105cd3:	c3                   	ret    

80105cd4 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105cd4:	55                   	push   %ebp
80105cd5:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105cd7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105cdd:	8b 00                	mov    (%eax),%eax
80105cdf:	3b 45 08             	cmp    0x8(%ebp),%eax
80105ce2:	76 12                	jbe    80105cf6 <fetchint+0x22>
80105ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80105ce7:	8d 50 04             	lea    0x4(%eax),%edx
80105cea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105cf0:	8b 00                	mov    (%eax),%eax
80105cf2:	39 c2                	cmp    %eax,%edx
80105cf4:	76 07                	jbe    80105cfd <fetchint+0x29>
    return -1;
80105cf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cfb:	eb 0f                	jmp    80105d0c <fetchint+0x38>
  *ip = *(int*)(addr);
80105cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80105d00:	8b 10                	mov    (%eax),%edx
80105d02:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d05:	89 10                	mov    %edx,(%eax)
  return 0;
80105d07:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d0c:	5d                   	pop    %ebp
80105d0d:	c3                   	ret    

80105d0e <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105d0e:	55                   	push   %ebp
80105d0f:	89 e5                	mov    %esp,%ebp
80105d11:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105d14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d1a:	8b 00                	mov    (%eax),%eax
80105d1c:	3b 45 08             	cmp    0x8(%ebp),%eax
80105d1f:	77 07                	ja     80105d28 <fetchstr+0x1a>
    return -1;
80105d21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d26:	eb 46                	jmp    80105d6e <fetchstr+0x60>
  *pp = (char*)addr;
80105d28:	8b 55 08             	mov    0x8(%ebp),%edx
80105d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d2e:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105d30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d36:	8b 00                	mov    (%eax),%eax
80105d38:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105d3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d3e:	8b 00                	mov    (%eax),%eax
80105d40:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105d43:	eb 1c                	jmp    80105d61 <fetchstr+0x53>
    if(*s == 0)
80105d45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d48:	0f b6 00             	movzbl (%eax),%eax
80105d4b:	84 c0                	test   %al,%al
80105d4d:	75 0e                	jne    80105d5d <fetchstr+0x4f>
      return s - *pp;
80105d4f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d52:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d55:	8b 00                	mov    (%eax),%eax
80105d57:	29 c2                	sub    %eax,%edx
80105d59:	89 d0                	mov    %edx,%eax
80105d5b:	eb 11                	jmp    80105d6e <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105d5d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105d61:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d64:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105d67:	72 dc                	jb     80105d45 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105d69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d6e:	c9                   	leave  
80105d6f:	c3                   	ret    

80105d70 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105d70:	55                   	push   %ebp
80105d71:	89 e5                	mov    %esp,%ebp
80105d73:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105d76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d7c:	8b 40 18             	mov    0x18(%eax),%eax
80105d7f:	8b 50 44             	mov    0x44(%eax),%edx
80105d82:	8b 45 08             	mov    0x8(%ebp),%eax
80105d85:	c1 e0 02             	shl    $0x2,%eax
80105d88:	01 d0                	add    %edx,%eax
80105d8a:	8d 50 04             	lea    0x4(%eax),%edx
80105d8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d90:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d94:	89 14 24             	mov    %edx,(%esp)
80105d97:	e8 38 ff ff ff       	call   80105cd4 <fetchint>
}
80105d9c:	c9                   	leave  
80105d9d:	c3                   	ret    

80105d9e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105d9e:	55                   	push   %ebp
80105d9f:	89 e5                	mov    %esp,%ebp
80105da1:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105da4:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105da7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dab:	8b 45 08             	mov    0x8(%ebp),%eax
80105dae:	89 04 24             	mov    %eax,(%esp)
80105db1:	e8 ba ff ff ff       	call   80105d70 <argint>
80105db6:	85 c0                	test   %eax,%eax
80105db8:	79 07                	jns    80105dc1 <argptr+0x23>
    return -1;
80105dba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dbf:	eb 3d                	jmp    80105dfe <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105dc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dc4:	89 c2                	mov    %eax,%edx
80105dc6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dcc:	8b 00                	mov    (%eax),%eax
80105dce:	39 c2                	cmp    %eax,%edx
80105dd0:	73 16                	jae    80105de8 <argptr+0x4a>
80105dd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dd5:	89 c2                	mov    %eax,%edx
80105dd7:	8b 45 10             	mov    0x10(%ebp),%eax
80105dda:	01 c2                	add    %eax,%edx
80105ddc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105de2:	8b 00                	mov    (%eax),%eax
80105de4:	39 c2                	cmp    %eax,%edx
80105de6:	76 07                	jbe    80105def <argptr+0x51>
    return -1;
80105de8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ded:	eb 0f                	jmp    80105dfe <argptr+0x60>
  *pp = (char*)i;
80105def:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105df2:	89 c2                	mov    %eax,%edx
80105df4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105df7:	89 10                	mov    %edx,(%eax)
  return 0;
80105df9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dfe:	c9                   	leave  
80105dff:	c3                   	ret    

80105e00 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105e00:	55                   	push   %ebp
80105e01:	89 e5                	mov    %esp,%ebp
80105e03:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105e06:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105e09:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80105e10:	89 04 24             	mov    %eax,(%esp)
80105e13:	e8 58 ff ff ff       	call   80105d70 <argint>
80105e18:	85 c0                	test   %eax,%eax
80105e1a:	79 07                	jns    80105e23 <argstr+0x23>
    return -1;
80105e1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e21:	eb 12                	jmp    80105e35 <argstr+0x35>
  return fetchstr(addr, pp);
80105e23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e26:	8b 55 0c             	mov    0xc(%ebp),%edx
80105e29:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e2d:	89 04 24             	mov    %eax,(%esp)
80105e30:	e8 d9 fe ff ff       	call   80105d0e <fetchstr>
}
80105e35:	c9                   	leave  
80105e36:	c3                   	ret    

80105e37 <syscall>:
[SYS_wait2]   sys_wait2,
};

void
syscall(void)
{
80105e37:	55                   	push   %ebp
80105e38:	89 e5                	mov    %esp,%ebp
80105e3a:	53                   	push   %ebx
80105e3b:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105e3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e44:	8b 40 18             	mov    0x18(%eax),%eax
80105e47:	8b 40 1c             	mov    0x1c(%eax),%eax
80105e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105e4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e51:	7e 30                	jle    80105e83 <syscall+0x4c>
80105e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e56:	83 f8 17             	cmp    $0x17,%eax
80105e59:	77 28                	ja     80105e83 <syscall+0x4c>
80105e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5e:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105e65:	85 c0                	test   %eax,%eax
80105e67:	74 1a                	je     80105e83 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105e69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e6f:	8b 58 18             	mov    0x18(%eax),%ebx
80105e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e75:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105e7c:	ff d0                	call   *%eax
80105e7e:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105e81:	eb 3d                	jmp    80105ec0 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105e83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e89:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105e8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105e92:	8b 40 10             	mov    0x10(%eax),%eax
80105e95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e98:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105e9c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ea4:	c7 04 24 2f 93 10 80 	movl   $0x8010932f,(%esp)
80105eab:	e8 f0 a4 ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105eb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105eb6:	8b 40 18             	mov    0x18(%eax),%eax
80105eb9:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105ec0:	83 c4 24             	add    $0x24,%esp
80105ec3:	5b                   	pop    %ebx
80105ec4:	5d                   	pop    %ebp
80105ec5:	c3                   	ret    

80105ec6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105ec6:	55                   	push   %ebp
80105ec7:	89 e5                	mov    %esp,%ebp
80105ec9:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105ecc:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ecf:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ed3:	8b 45 08             	mov    0x8(%ebp),%eax
80105ed6:	89 04 24             	mov    %eax,(%esp)
80105ed9:	e8 92 fe ff ff       	call   80105d70 <argint>
80105ede:	85 c0                	test   %eax,%eax
80105ee0:	79 07                	jns    80105ee9 <argfd+0x23>
    return -1;
80105ee2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ee7:	eb 50                	jmp    80105f39 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eec:	85 c0                	test   %eax,%eax
80105eee:	78 21                	js     80105f11 <argfd+0x4b>
80105ef0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef3:	83 f8 0f             	cmp    $0xf,%eax
80105ef6:	7f 19                	jg     80105f11 <argfd+0x4b>
80105ef8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105efe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f01:	83 c2 08             	add    $0x8,%edx
80105f04:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105f08:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f0f:	75 07                	jne    80105f18 <argfd+0x52>
    return -1;
80105f11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f16:	eb 21                	jmp    80105f39 <argfd+0x73>
  if(pfd)
80105f18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105f1c:	74 08                	je     80105f26 <argfd+0x60>
    *pfd = fd;
80105f1e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f21:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f24:	89 10                	mov    %edx,(%eax)
  if(pf)
80105f26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f2a:	74 08                	je     80105f34 <argfd+0x6e>
    *pf = f;
80105f2c:	8b 45 10             	mov    0x10(%ebp),%eax
80105f2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f32:	89 10                	mov    %edx,(%eax)
  return 0;
80105f34:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f39:	c9                   	leave  
80105f3a:	c3                   	ret    

80105f3b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105f3b:	55                   	push   %ebp
80105f3c:	89 e5                	mov    %esp,%ebp
80105f3e:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105f41:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105f48:	eb 30                	jmp    80105f7a <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105f4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f50:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f53:	83 c2 08             	add    $0x8,%edx
80105f56:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105f5a:	85 c0                	test   %eax,%eax
80105f5c:	75 18                	jne    80105f76 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105f5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f64:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f67:	8d 4a 08             	lea    0x8(%edx),%ecx
80105f6a:	8b 55 08             	mov    0x8(%ebp),%edx
80105f6d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105f71:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f74:	eb 0f                	jmp    80105f85 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105f76:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f7a:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105f7e:	7e ca                	jle    80105f4a <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105f80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f85:	c9                   	leave  
80105f86:	c3                   	ret    

80105f87 <sys_dup>:

int
sys_dup(void)
{
80105f87:	55                   	push   %ebp
80105f88:	89 e5                	mov    %esp,%ebp
80105f8a:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105f8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f90:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f9b:	00 
80105f9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fa3:	e8 1e ff ff ff       	call   80105ec6 <argfd>
80105fa8:	85 c0                	test   %eax,%eax
80105faa:	79 07                	jns    80105fb3 <sys_dup+0x2c>
    return -1;
80105fac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb1:	eb 29                	jmp    80105fdc <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb6:	89 04 24             	mov    %eax,(%esp)
80105fb9:	e8 7d ff ff ff       	call   80105f3b <fdalloc>
80105fbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fc1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fc5:	79 07                	jns    80105fce <sys_dup+0x47>
    return -1;
80105fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fcc:	eb 0e                	jmp    80105fdc <sys_dup+0x55>
  filedup(f);
80105fce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd1:	89 04 24             	mov    %eax,(%esp)
80105fd4:	e8 0e b7 ff ff       	call   801016e7 <filedup>
  return fd;
80105fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105fdc:	c9                   	leave  
80105fdd:	c3                   	ret    

80105fde <sys_read>:

int
sys_read(void)
{
80105fde:	55                   	push   %ebp
80105fdf:	89 e5                	mov    %esp,%ebp
80105fe1:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fe7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105feb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ff2:	00 
80105ff3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ffa:	e8 c7 fe ff ff       	call   80105ec6 <argfd>
80105fff:	85 c0                	test   %eax,%eax
80106001:	78 35                	js     80106038 <sys_read+0x5a>
80106003:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106006:	89 44 24 04          	mov    %eax,0x4(%esp)
8010600a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106011:	e8 5a fd ff ff       	call   80105d70 <argint>
80106016:	85 c0                	test   %eax,%eax
80106018:	78 1e                	js     80106038 <sys_read+0x5a>
8010601a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106021:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106024:	89 44 24 04          	mov    %eax,0x4(%esp)
80106028:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010602f:	e8 6a fd ff ff       	call   80105d9e <argptr>
80106034:	85 c0                	test   %eax,%eax
80106036:	79 07                	jns    8010603f <sys_read+0x61>
    return -1;
80106038:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603d:	eb 19                	jmp    80106058 <sys_read+0x7a>
  return fileread(f, p, n);
8010603f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106042:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106048:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010604c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106050:	89 04 24             	mov    %eax,(%esp)
80106053:	e8 fc b7 ff ff       	call   80101854 <fileread>
}
80106058:	c9                   	leave  
80106059:	c3                   	ret    

8010605a <sys_write>:

int
sys_write(void)
{
8010605a:	55                   	push   %ebp
8010605b:	89 e5                	mov    %esp,%ebp
8010605d:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106060:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106063:	89 44 24 08          	mov    %eax,0x8(%esp)
80106067:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010606e:	00 
8010606f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106076:	e8 4b fe ff ff       	call   80105ec6 <argfd>
8010607b:	85 c0                	test   %eax,%eax
8010607d:	78 35                	js     801060b4 <sys_write+0x5a>
8010607f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106082:	89 44 24 04          	mov    %eax,0x4(%esp)
80106086:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010608d:	e8 de fc ff ff       	call   80105d70 <argint>
80106092:	85 c0                	test   %eax,%eax
80106094:	78 1e                	js     801060b4 <sys_write+0x5a>
80106096:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106099:	89 44 24 08          	mov    %eax,0x8(%esp)
8010609d:	8d 45 ec             	lea    -0x14(%ebp),%eax
801060a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801060a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801060ab:	e8 ee fc ff ff       	call   80105d9e <argptr>
801060b0:	85 c0                	test   %eax,%eax
801060b2:	79 07                	jns    801060bb <sys_write+0x61>
    return -1;
801060b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b9:	eb 19                	jmp    801060d4 <sys_write+0x7a>
  return filewrite(f, p, n);
801060bb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801060be:	8b 55 ec             	mov    -0x14(%ebp),%edx
801060c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801060c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801060cc:	89 04 24             	mov    %eax,(%esp)
801060cf:	e8 3c b8 ff ff       	call   80101910 <filewrite>
}
801060d4:	c9                   	leave  
801060d5:	c3                   	ret    

801060d6 <sys_close>:

int
sys_close(void)
{
801060d6:	55                   	push   %ebp
801060d7:	89 e5                	mov    %esp,%ebp
801060d9:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801060dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060df:	89 44 24 08          	mov    %eax,0x8(%esp)
801060e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801060ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060f1:	e8 d0 fd ff ff       	call   80105ec6 <argfd>
801060f6:	85 c0                	test   %eax,%eax
801060f8:	79 07                	jns    80106101 <sys_close+0x2b>
    return -1;
801060fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ff:	eb 24                	jmp    80106125 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80106101:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106107:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010610a:	83 c2 08             	add    $0x8,%edx
8010610d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106114:	00 
  fileclose(f);
80106115:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106118:	89 04 24             	mov    %eax,(%esp)
8010611b:	e8 0f b6 ff ff       	call   8010172f <fileclose>
  return 0;
80106120:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106125:	c9                   	leave  
80106126:	c3                   	ret    

80106127 <sys_fstat>:

int
sys_fstat(void)
{
80106127:	55                   	push   %ebp
80106128:	89 e5                	mov    %esp,%ebp
8010612a:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010612d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106130:	89 44 24 08          	mov    %eax,0x8(%esp)
80106134:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010613b:	00 
8010613c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106143:	e8 7e fd ff ff       	call   80105ec6 <argfd>
80106148:	85 c0                	test   %eax,%eax
8010614a:	78 1f                	js     8010616b <sys_fstat+0x44>
8010614c:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80106153:	00 
80106154:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106157:	89 44 24 04          	mov    %eax,0x4(%esp)
8010615b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106162:	e8 37 fc ff ff       	call   80105d9e <argptr>
80106167:	85 c0                	test   %eax,%eax
80106169:	79 07                	jns    80106172 <sys_fstat+0x4b>
    return -1;
8010616b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106170:	eb 12                	jmp    80106184 <sys_fstat+0x5d>
  return filestat(f, st);
80106172:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106178:	89 54 24 04          	mov    %edx,0x4(%esp)
8010617c:	89 04 24             	mov    %eax,(%esp)
8010617f:	e8 81 b6 ff ff       	call   80101805 <filestat>
}
80106184:	c9                   	leave  
80106185:	c3                   	ret    

80106186 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106186:	55                   	push   %ebp
80106187:	89 e5                	mov    %esp,%ebp
80106189:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010618c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010618f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106193:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010619a:	e8 61 fc ff ff       	call   80105e00 <argstr>
8010619f:	85 c0                	test   %eax,%eax
801061a1:	78 17                	js     801061ba <sys_link+0x34>
801061a3:	8d 45 dc             	lea    -0x24(%ebp),%eax
801061a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801061aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801061b1:	e8 4a fc ff ff       	call   80105e00 <argstr>
801061b6:	85 c0                	test   %eax,%eax
801061b8:	79 0a                	jns    801061c4 <sys_link+0x3e>
    return -1;
801061ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061bf:	e9 42 01 00 00       	jmp    80106306 <sys_link+0x180>

  begin_op();
801061c4:	e8 39 da ff ff       	call   80103c02 <begin_op>
  if((ip = namei(old)) == 0){
801061c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801061cc:	89 04 24             	mov    %eax,(%esp)
801061cf:	e8 f7 c9 ff ff       	call   80102bcb <namei>
801061d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061db:	75 0f                	jne    801061ec <sys_link+0x66>
    end_op();
801061dd:	e8 a4 da ff ff       	call   80103c86 <end_op>
    return -1;
801061e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e7:	e9 1a 01 00 00       	jmp    80106306 <sys_link+0x180>
  }

  ilock(ip);
801061ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ef:	89 04 24             	mov    %eax,(%esp)
801061f2:	e8 23 be ff ff       	call   8010201a <ilock>
  if(ip->type == T_DIR){
801061f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061fa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061fe:	66 83 f8 01          	cmp    $0x1,%ax
80106202:	75 1a                	jne    8010621e <sys_link+0x98>
    iunlockput(ip);
80106204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106207:	89 04 24             	mov    %eax,(%esp)
8010620a:	e8 95 c0 ff ff       	call   801022a4 <iunlockput>
    end_op();
8010620f:	e8 72 da ff ff       	call   80103c86 <end_op>
    return -1;
80106214:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106219:	e9 e8 00 00 00       	jmp    80106306 <sys_link+0x180>
  }

  ip->nlink++;
8010621e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106221:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106225:	8d 50 01             	lea    0x1(%eax),%edx
80106228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622b:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010622f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106232:	89 04 24             	mov    %eax,(%esp)
80106235:	e8 1e bc ff ff       	call   80101e58 <iupdate>
  iunlock(ip);
8010623a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623d:	89 04 24             	mov    %eax,(%esp)
80106240:	e8 29 bf ff ff       	call   8010216e <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80106245:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106248:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010624b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010624f:	89 04 24             	mov    %eax,(%esp)
80106252:	e8 96 c9 ff ff       	call   80102bed <nameiparent>
80106257:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010625a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010625e:	75 02                	jne    80106262 <sys_link+0xdc>
    goto bad;
80106260:	eb 68                	jmp    801062ca <sys_link+0x144>
  ilock(dp);
80106262:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106265:	89 04 24             	mov    %eax,(%esp)
80106268:	e8 ad bd ff ff       	call   8010201a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010626d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106270:	8b 10                	mov    (%eax),%edx
80106272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106275:	8b 00                	mov    (%eax),%eax
80106277:	39 c2                	cmp    %eax,%edx
80106279:	75 20                	jne    8010629b <sys_link+0x115>
8010627b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627e:	8b 40 04             	mov    0x4(%eax),%eax
80106281:	89 44 24 08          	mov    %eax,0x8(%esp)
80106285:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106288:	89 44 24 04          	mov    %eax,0x4(%esp)
8010628c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010628f:	89 04 24             	mov    %eax,(%esp)
80106292:	e8 74 c6 ff ff       	call   8010290b <dirlink>
80106297:	85 c0                	test   %eax,%eax
80106299:	79 0d                	jns    801062a8 <sys_link+0x122>
    iunlockput(dp);
8010629b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629e:	89 04 24             	mov    %eax,(%esp)
801062a1:	e8 fe bf ff ff       	call   801022a4 <iunlockput>
    goto bad;
801062a6:	eb 22                	jmp    801062ca <sys_link+0x144>
  }
  iunlockput(dp);
801062a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ab:	89 04 24             	mov    %eax,(%esp)
801062ae:	e8 f1 bf ff ff       	call   801022a4 <iunlockput>
  iput(ip);
801062b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b6:	89 04 24             	mov    %eax,(%esp)
801062b9:	e8 15 bf ff ff       	call   801021d3 <iput>

  end_op();
801062be:	e8 c3 d9 ff ff       	call   80103c86 <end_op>

  return 0;
801062c3:	b8 00 00 00 00       	mov    $0x0,%eax
801062c8:	eb 3c                	jmp    80106306 <sys_link+0x180>

bad:
  ilock(ip);
801062ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062cd:	89 04 24             	mov    %eax,(%esp)
801062d0:	e8 45 bd ff ff       	call   8010201a <ilock>
  ip->nlink--;
801062d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801062dc:	8d 50 ff             	lea    -0x1(%eax),%edx
801062df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e2:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801062e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e9:	89 04 24             	mov    %eax,(%esp)
801062ec:	e8 67 bb ff ff       	call   80101e58 <iupdate>
  iunlockput(ip);
801062f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f4:	89 04 24             	mov    %eax,(%esp)
801062f7:	e8 a8 bf ff ff       	call   801022a4 <iunlockput>
  end_op();
801062fc:	e8 85 d9 ff ff       	call   80103c86 <end_op>
  return -1;
80106301:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106306:	c9                   	leave  
80106307:	c3                   	ret    

80106308 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106308:	55                   	push   %ebp
80106309:	89 e5                	mov    %esp,%ebp
8010630b:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010630e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106315:	eb 4b                	jmp    80106362 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106317:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106321:	00 
80106322:	89 44 24 08          	mov    %eax,0x8(%esp)
80106326:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106329:	89 44 24 04          	mov    %eax,0x4(%esp)
8010632d:	8b 45 08             	mov    0x8(%ebp),%eax
80106330:	89 04 24             	mov    %eax,(%esp)
80106333:	e8 f5 c1 ff ff       	call   8010252d <readi>
80106338:	83 f8 10             	cmp    $0x10,%eax
8010633b:	74 0c                	je     80106349 <isdirempty+0x41>
      panic("isdirempty: readi");
8010633d:	c7 04 24 4b 93 10 80 	movl   $0x8010934b,(%esp)
80106344:	e8 f1 a1 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80106349:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010634d:	66 85 c0             	test   %ax,%ax
80106350:	74 07                	je     80106359 <isdirempty+0x51>
      return 0;
80106352:	b8 00 00 00 00       	mov    $0x0,%eax
80106357:	eb 1b                	jmp    80106374 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635c:	83 c0 10             	add    $0x10,%eax
8010635f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106362:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106365:	8b 45 08             	mov    0x8(%ebp),%eax
80106368:	8b 40 18             	mov    0x18(%eax),%eax
8010636b:	39 c2                	cmp    %eax,%edx
8010636d:	72 a8                	jb     80106317 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010636f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106374:	c9                   	leave  
80106375:	c3                   	ret    

80106376 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106376:	55                   	push   %ebp
80106377:	89 e5                	mov    %esp,%ebp
80106379:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010637c:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010637f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106383:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010638a:	e8 71 fa ff ff       	call   80105e00 <argstr>
8010638f:	85 c0                	test   %eax,%eax
80106391:	79 0a                	jns    8010639d <sys_unlink+0x27>
    return -1;
80106393:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106398:	e9 af 01 00 00       	jmp    8010654c <sys_unlink+0x1d6>

  begin_op();
8010639d:	e8 60 d8 ff ff       	call   80103c02 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801063a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
801063a5:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801063a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801063ac:	89 04 24             	mov    %eax,(%esp)
801063af:	e8 39 c8 ff ff       	call   80102bed <nameiparent>
801063b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063bb:	75 0f                	jne    801063cc <sys_unlink+0x56>
    end_op();
801063bd:	e8 c4 d8 ff ff       	call   80103c86 <end_op>
    return -1;
801063c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c7:	e9 80 01 00 00       	jmp    8010654c <sys_unlink+0x1d6>
  }

  ilock(dp);
801063cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063cf:	89 04 24             	mov    %eax,(%esp)
801063d2:	e8 43 bc ff ff       	call   8010201a <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801063d7:	c7 44 24 04 5d 93 10 	movl   $0x8010935d,0x4(%esp)
801063de:	80 
801063df:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801063e2:	89 04 24             	mov    %eax,(%esp)
801063e5:	e8 36 c4 ff ff       	call   80102820 <namecmp>
801063ea:	85 c0                	test   %eax,%eax
801063ec:	0f 84 45 01 00 00    	je     80106537 <sys_unlink+0x1c1>
801063f2:	c7 44 24 04 5f 93 10 	movl   $0x8010935f,0x4(%esp)
801063f9:	80 
801063fa:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801063fd:	89 04 24             	mov    %eax,(%esp)
80106400:	e8 1b c4 ff ff       	call   80102820 <namecmp>
80106405:	85 c0                	test   %eax,%eax
80106407:	0f 84 2a 01 00 00    	je     80106537 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010640d:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106410:	89 44 24 08          	mov    %eax,0x8(%esp)
80106414:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106417:	89 44 24 04          	mov    %eax,0x4(%esp)
8010641b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010641e:	89 04 24             	mov    %eax,(%esp)
80106421:	e8 1c c4 ff ff       	call   80102842 <dirlookup>
80106426:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106429:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010642d:	75 05                	jne    80106434 <sys_unlink+0xbe>
    goto bad;
8010642f:	e9 03 01 00 00       	jmp    80106537 <sys_unlink+0x1c1>
  ilock(ip);
80106434:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106437:	89 04 24             	mov    %eax,(%esp)
8010643a:	e8 db bb ff ff       	call   8010201a <ilock>

  if(ip->nlink < 1)
8010643f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106442:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106446:	66 85 c0             	test   %ax,%ax
80106449:	7f 0c                	jg     80106457 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
8010644b:	c7 04 24 62 93 10 80 	movl   $0x80109362,(%esp)
80106452:	e8 e3 a0 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010645a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010645e:	66 83 f8 01          	cmp    $0x1,%ax
80106462:	75 1f                	jne    80106483 <sys_unlink+0x10d>
80106464:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106467:	89 04 24             	mov    %eax,(%esp)
8010646a:	e8 99 fe ff ff       	call   80106308 <isdirempty>
8010646f:	85 c0                	test   %eax,%eax
80106471:	75 10                	jne    80106483 <sys_unlink+0x10d>
    iunlockput(ip);
80106473:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106476:	89 04 24             	mov    %eax,(%esp)
80106479:	e8 26 be ff ff       	call   801022a4 <iunlockput>
    goto bad;
8010647e:	e9 b4 00 00 00       	jmp    80106537 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80106483:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010648a:	00 
8010648b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106492:	00 
80106493:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106496:	89 04 24             	mov    %eax,(%esp)
80106499:	e8 90 f5 ff ff       	call   80105a2e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010649e:	8b 45 c8             	mov    -0x38(%ebp),%eax
801064a1:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801064a8:	00 
801064a9:	89 44 24 08          	mov    %eax,0x8(%esp)
801064ad:	8d 45 e0             	lea    -0x20(%ebp),%eax
801064b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801064b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b7:	89 04 24             	mov    %eax,(%esp)
801064ba:	e8 d2 c1 ff ff       	call   80102691 <writei>
801064bf:	83 f8 10             	cmp    $0x10,%eax
801064c2:	74 0c                	je     801064d0 <sys_unlink+0x15a>
    panic("unlink: writei");
801064c4:	c7 04 24 74 93 10 80 	movl   $0x80109374,(%esp)
801064cb:	e8 6a a0 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
801064d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801064d7:	66 83 f8 01          	cmp    $0x1,%ax
801064db:	75 1c                	jne    801064f9 <sys_unlink+0x183>
    dp->nlink--;
801064dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801064e4:	8d 50 ff             	lea    -0x1(%eax),%edx
801064e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ea:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801064ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f1:	89 04 24             	mov    %eax,(%esp)
801064f4:	e8 5f b9 ff ff       	call   80101e58 <iupdate>
  }
  iunlockput(dp);
801064f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064fc:	89 04 24             	mov    %eax,(%esp)
801064ff:	e8 a0 bd ff ff       	call   801022a4 <iunlockput>

  ip->nlink--;
80106504:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106507:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010650b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010650e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106511:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106515:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106518:	89 04 24             	mov    %eax,(%esp)
8010651b:	e8 38 b9 ff ff       	call   80101e58 <iupdate>
  iunlockput(ip);
80106520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106523:	89 04 24             	mov    %eax,(%esp)
80106526:	e8 79 bd ff ff       	call   801022a4 <iunlockput>

  end_op();
8010652b:	e8 56 d7 ff ff       	call   80103c86 <end_op>

  return 0;
80106530:	b8 00 00 00 00       	mov    $0x0,%eax
80106535:	eb 15                	jmp    8010654c <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80106537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010653a:	89 04 24             	mov    %eax,(%esp)
8010653d:	e8 62 bd ff ff       	call   801022a4 <iunlockput>
  end_op();
80106542:	e8 3f d7 ff ff       	call   80103c86 <end_op>
  return -1;
80106547:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010654c:	c9                   	leave  
8010654d:	c3                   	ret    

8010654e <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010654e:	55                   	push   %ebp
8010654f:	89 e5                	mov    %esp,%ebp
80106551:	83 ec 48             	sub    $0x48,%esp
80106554:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106557:	8b 55 10             	mov    0x10(%ebp),%edx
8010655a:	8b 45 14             	mov    0x14(%ebp),%eax
8010655d:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106561:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106565:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106569:	8d 45 de             	lea    -0x22(%ebp),%eax
8010656c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106570:	8b 45 08             	mov    0x8(%ebp),%eax
80106573:	89 04 24             	mov    %eax,(%esp)
80106576:	e8 72 c6 ff ff       	call   80102bed <nameiparent>
8010657b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010657e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106582:	75 0a                	jne    8010658e <create+0x40>
    return 0;
80106584:	b8 00 00 00 00       	mov    $0x0,%eax
80106589:	e9 7e 01 00 00       	jmp    8010670c <create+0x1be>
  ilock(dp);
8010658e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106591:	89 04 24             	mov    %eax,(%esp)
80106594:	e8 81 ba ff ff       	call   8010201a <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80106599:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010659c:	89 44 24 08          	mov    %eax,0x8(%esp)
801065a0:	8d 45 de             	lea    -0x22(%ebp),%eax
801065a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801065a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065aa:	89 04 24             	mov    %eax,(%esp)
801065ad:	e8 90 c2 ff ff       	call   80102842 <dirlookup>
801065b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065b9:	74 47                	je     80106602 <create+0xb4>
    iunlockput(dp);
801065bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065be:	89 04 24             	mov    %eax,(%esp)
801065c1:	e8 de bc ff ff       	call   801022a4 <iunlockput>
    ilock(ip);
801065c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c9:	89 04 24             	mov    %eax,(%esp)
801065cc:	e8 49 ba ff ff       	call   8010201a <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801065d1:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801065d6:	75 15                	jne    801065ed <create+0x9f>
801065d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065db:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065df:	66 83 f8 02          	cmp    $0x2,%ax
801065e3:	75 08                	jne    801065ed <create+0x9f>
      return ip;
801065e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e8:	e9 1f 01 00 00       	jmp    8010670c <create+0x1be>
    iunlockput(ip);
801065ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f0:	89 04 24             	mov    %eax,(%esp)
801065f3:	e8 ac bc ff ff       	call   801022a4 <iunlockput>
    return 0;
801065f8:	b8 00 00 00 00       	mov    $0x0,%eax
801065fd:	e9 0a 01 00 00       	jmp    8010670c <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106602:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106609:	8b 00                	mov    (%eax),%eax
8010660b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010660f:	89 04 24             	mov    %eax,(%esp)
80106612:	e8 6c b7 ff ff       	call   80101d83 <ialloc>
80106617:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010661a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010661e:	75 0c                	jne    8010662c <create+0xde>
    panic("create: ialloc");
80106620:	c7 04 24 83 93 10 80 	movl   $0x80109383,(%esp)
80106627:	e8 0e 9f ff ff       	call   8010053a <panic>

  ilock(ip);
8010662c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010662f:	89 04 24             	mov    %eax,(%esp)
80106632:	e8 e3 b9 ff ff       	call   8010201a <ilock>
  ip->major = major;
80106637:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010663a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010663e:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106642:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106645:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106649:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010664d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106650:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106659:	89 04 24             	mov    %eax,(%esp)
8010665c:	e8 f7 b7 ff ff       	call   80101e58 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106661:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106666:	75 6a                	jne    801066d2 <create+0x184>
    dp->nlink++;  // for ".."
80106668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010666f:	8d 50 01             	lea    0x1(%eax),%edx
80106672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106675:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010667c:	89 04 24             	mov    %eax,(%esp)
8010667f:	e8 d4 b7 ff ff       	call   80101e58 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106684:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106687:	8b 40 04             	mov    0x4(%eax),%eax
8010668a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010668e:	c7 44 24 04 5d 93 10 	movl   $0x8010935d,0x4(%esp)
80106695:	80 
80106696:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106699:	89 04 24             	mov    %eax,(%esp)
8010669c:	e8 6a c2 ff ff       	call   8010290b <dirlink>
801066a1:	85 c0                	test   %eax,%eax
801066a3:	78 21                	js     801066c6 <create+0x178>
801066a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a8:	8b 40 04             	mov    0x4(%eax),%eax
801066ab:	89 44 24 08          	mov    %eax,0x8(%esp)
801066af:	c7 44 24 04 5f 93 10 	movl   $0x8010935f,0x4(%esp)
801066b6:	80 
801066b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066ba:	89 04 24             	mov    %eax,(%esp)
801066bd:	e8 49 c2 ff ff       	call   8010290b <dirlink>
801066c2:	85 c0                	test   %eax,%eax
801066c4:	79 0c                	jns    801066d2 <create+0x184>
      panic("create dots");
801066c6:	c7 04 24 92 93 10 80 	movl   $0x80109392,(%esp)
801066cd:	e8 68 9e ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801066d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066d5:	8b 40 04             	mov    0x4(%eax),%eax
801066d8:	89 44 24 08          	mov    %eax,0x8(%esp)
801066dc:	8d 45 de             	lea    -0x22(%ebp),%eax
801066df:	89 44 24 04          	mov    %eax,0x4(%esp)
801066e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e6:	89 04 24             	mov    %eax,(%esp)
801066e9:	e8 1d c2 ff ff       	call   8010290b <dirlink>
801066ee:	85 c0                	test   %eax,%eax
801066f0:	79 0c                	jns    801066fe <create+0x1b0>
    panic("create: dirlink");
801066f2:	c7 04 24 9e 93 10 80 	movl   $0x8010939e,(%esp)
801066f9:	e8 3c 9e ff ff       	call   8010053a <panic>

  iunlockput(dp);
801066fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106701:	89 04 24             	mov    %eax,(%esp)
80106704:	e8 9b bb ff ff       	call   801022a4 <iunlockput>

  return ip;
80106709:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010670c:	c9                   	leave  
8010670d:	c3                   	ret    

8010670e <sys_open>:

int
sys_open(void)
{
8010670e:	55                   	push   %ebp
8010670f:	89 e5                	mov    %esp,%ebp
80106711:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106714:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106717:	89 44 24 04          	mov    %eax,0x4(%esp)
8010671b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106722:	e8 d9 f6 ff ff       	call   80105e00 <argstr>
80106727:	85 c0                	test   %eax,%eax
80106729:	78 17                	js     80106742 <sys_open+0x34>
8010672b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010672e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106732:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106739:	e8 32 f6 ff ff       	call   80105d70 <argint>
8010673e:	85 c0                	test   %eax,%eax
80106740:	79 0a                	jns    8010674c <sys_open+0x3e>
    return -1;
80106742:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106747:	e9 5c 01 00 00       	jmp    801068a8 <sys_open+0x19a>

  begin_op();
8010674c:	e8 b1 d4 ff ff       	call   80103c02 <begin_op>

  if(omode & O_CREATE){
80106751:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106754:	25 00 02 00 00       	and    $0x200,%eax
80106759:	85 c0                	test   %eax,%eax
8010675b:	74 3b                	je     80106798 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010675d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106760:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106767:	00 
80106768:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010676f:	00 
80106770:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106777:	00 
80106778:	89 04 24             	mov    %eax,(%esp)
8010677b:	e8 ce fd ff ff       	call   8010654e <create>
80106780:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106783:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106787:	75 6b                	jne    801067f4 <sys_open+0xe6>
      end_op();
80106789:	e8 f8 d4 ff ff       	call   80103c86 <end_op>
      return -1;
8010678e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106793:	e9 10 01 00 00       	jmp    801068a8 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80106798:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010679b:	89 04 24             	mov    %eax,(%esp)
8010679e:	e8 28 c4 ff ff       	call   80102bcb <namei>
801067a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067aa:	75 0f                	jne    801067bb <sys_open+0xad>
      end_op();
801067ac:	e8 d5 d4 ff ff       	call   80103c86 <end_op>
      return -1;
801067b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b6:	e9 ed 00 00 00       	jmp    801068a8 <sys_open+0x19a>
    }
    ilock(ip);
801067bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067be:	89 04 24             	mov    %eax,(%esp)
801067c1:	e8 54 b8 ff ff       	call   8010201a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801067c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801067cd:	66 83 f8 01          	cmp    $0x1,%ax
801067d1:	75 21                	jne    801067f4 <sys_open+0xe6>
801067d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067d6:	85 c0                	test   %eax,%eax
801067d8:	74 1a                	je     801067f4 <sys_open+0xe6>
      iunlockput(ip);
801067da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067dd:	89 04 24             	mov    %eax,(%esp)
801067e0:	e8 bf ba ff ff       	call   801022a4 <iunlockput>
      end_op();
801067e5:	e8 9c d4 ff ff       	call   80103c86 <end_op>
      return -1;
801067ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067ef:	e9 b4 00 00 00       	jmp    801068a8 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801067f4:	e8 8e ae ff ff       	call   80101687 <filealloc>
801067f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106800:	74 14                	je     80106816 <sys_open+0x108>
80106802:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106805:	89 04 24             	mov    %eax,(%esp)
80106808:	e8 2e f7 ff ff       	call   80105f3b <fdalloc>
8010680d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106810:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106814:	79 28                	jns    8010683e <sys_open+0x130>
    if(f)
80106816:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010681a:	74 0b                	je     80106827 <sys_open+0x119>
      fileclose(f);
8010681c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010681f:	89 04 24             	mov    %eax,(%esp)
80106822:	e8 08 af ff ff       	call   8010172f <fileclose>
    iunlockput(ip);
80106827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682a:	89 04 24             	mov    %eax,(%esp)
8010682d:	e8 72 ba ff ff       	call   801022a4 <iunlockput>
    end_op();
80106832:	e8 4f d4 ff ff       	call   80103c86 <end_op>
    return -1;
80106837:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010683c:	eb 6a                	jmp    801068a8 <sys_open+0x19a>
  }
  iunlock(ip);
8010683e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106841:	89 04 24             	mov    %eax,(%esp)
80106844:	e8 25 b9 ff ff       	call   8010216e <iunlock>
  end_op();
80106849:	e8 38 d4 ff ff       	call   80103c86 <end_op>

  f->type = FD_INODE;
8010684e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106851:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106857:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010685a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010685d:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106863:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010686a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010686d:	83 e0 01             	and    $0x1,%eax
80106870:	85 c0                	test   %eax,%eax
80106872:	0f 94 c0             	sete   %al
80106875:	89 c2                	mov    %eax,%edx
80106877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010687a:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010687d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106880:	83 e0 01             	and    $0x1,%eax
80106883:	85 c0                	test   %eax,%eax
80106885:	75 0a                	jne    80106891 <sys_open+0x183>
80106887:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010688a:	83 e0 02             	and    $0x2,%eax
8010688d:	85 c0                	test   %eax,%eax
8010688f:	74 07                	je     80106898 <sys_open+0x18a>
80106891:	b8 01 00 00 00       	mov    $0x1,%eax
80106896:	eb 05                	jmp    8010689d <sys_open+0x18f>
80106898:	b8 00 00 00 00       	mov    $0x0,%eax
8010689d:	89 c2                	mov    %eax,%edx
8010689f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068a2:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801068a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801068a8:	c9                   	leave  
801068a9:	c3                   	ret    

801068aa <sys_mkdir>:

int
sys_mkdir(void)
{
801068aa:	55                   	push   %ebp
801068ab:	89 e5                	mov    %esp,%ebp
801068ad:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801068b0:	e8 4d d3 ff ff       	call   80103c02 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801068b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801068bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068c3:	e8 38 f5 ff ff       	call   80105e00 <argstr>
801068c8:	85 c0                	test   %eax,%eax
801068ca:	78 2c                	js     801068f8 <sys_mkdir+0x4e>
801068cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801068d6:	00 
801068d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801068de:	00 
801068df:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801068e6:	00 
801068e7:	89 04 24             	mov    %eax,(%esp)
801068ea:	e8 5f fc ff ff       	call   8010654e <create>
801068ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068f6:	75 0c                	jne    80106904 <sys_mkdir+0x5a>
    end_op();
801068f8:	e8 89 d3 ff ff       	call   80103c86 <end_op>
    return -1;
801068fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106902:	eb 15                	jmp    80106919 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106907:	89 04 24             	mov    %eax,(%esp)
8010690a:	e8 95 b9 ff ff       	call   801022a4 <iunlockput>
  end_op();
8010690f:	e8 72 d3 ff ff       	call   80103c86 <end_op>
  return 0;
80106914:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106919:	c9                   	leave  
8010691a:	c3                   	ret    

8010691b <sys_mknod>:

int
sys_mknod(void)
{
8010691b:	55                   	push   %ebp
8010691c:	89 e5                	mov    %esp,%ebp
8010691e:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106921:	e8 dc d2 ff ff       	call   80103c02 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106926:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106929:	89 44 24 04          	mov    %eax,0x4(%esp)
8010692d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106934:	e8 c7 f4 ff ff       	call   80105e00 <argstr>
80106939:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010693c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106940:	78 5e                	js     801069a0 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106942:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106945:	89 44 24 04          	mov    %eax,0x4(%esp)
80106949:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106950:	e8 1b f4 ff ff       	call   80105d70 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106955:	85 c0                	test   %eax,%eax
80106957:	78 47                	js     801069a0 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106959:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010695c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106960:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106967:	e8 04 f4 ff ff       	call   80105d70 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010696c:	85 c0                	test   %eax,%eax
8010696e:	78 30                	js     801069a0 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106970:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106973:	0f bf c8             	movswl %ax,%ecx
80106976:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106979:	0f bf d0             	movswl %ax,%edx
8010697c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010697f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106983:	89 54 24 08          	mov    %edx,0x8(%esp)
80106987:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010698e:	00 
8010698f:	89 04 24             	mov    %eax,(%esp)
80106992:	e8 b7 fb ff ff       	call   8010654e <create>
80106997:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010699a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010699e:	75 0c                	jne    801069ac <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801069a0:	e8 e1 d2 ff ff       	call   80103c86 <end_op>
    return -1;
801069a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069aa:	eb 15                	jmp    801069c1 <sys_mknod+0xa6>
  }
  iunlockput(ip);
801069ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069af:	89 04 24             	mov    %eax,(%esp)
801069b2:	e8 ed b8 ff ff       	call   801022a4 <iunlockput>
  end_op();
801069b7:	e8 ca d2 ff ff       	call   80103c86 <end_op>
  return 0;
801069bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069c1:	c9                   	leave  
801069c2:	c3                   	ret    

801069c3 <sys_chdir>:

int
sys_chdir(void)
{
801069c3:	55                   	push   %ebp
801069c4:	89 e5                	mov    %esp,%ebp
801069c6:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801069c9:	e8 34 d2 ff ff       	call   80103c02 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801069ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801069d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069dc:	e8 1f f4 ff ff       	call   80105e00 <argstr>
801069e1:	85 c0                	test   %eax,%eax
801069e3:	78 14                	js     801069f9 <sys_chdir+0x36>
801069e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069e8:	89 04 24             	mov    %eax,(%esp)
801069eb:	e8 db c1 ff ff       	call   80102bcb <namei>
801069f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069f7:	75 0c                	jne    80106a05 <sys_chdir+0x42>
    end_op();
801069f9:	e8 88 d2 ff ff       	call   80103c86 <end_op>
    return -1;
801069fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a03:	eb 61                	jmp    80106a66 <sys_chdir+0xa3>
  }
  ilock(ip);
80106a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a08:	89 04 24             	mov    %eax,(%esp)
80106a0b:	e8 0a b6 ff ff       	call   8010201a <ilock>
  if(ip->type != T_DIR){
80106a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a13:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a17:	66 83 f8 01          	cmp    $0x1,%ax
80106a1b:	74 17                	je     80106a34 <sys_chdir+0x71>
    iunlockput(ip);
80106a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a20:	89 04 24             	mov    %eax,(%esp)
80106a23:	e8 7c b8 ff ff       	call   801022a4 <iunlockput>
    end_op();
80106a28:	e8 59 d2 ff ff       	call   80103c86 <end_op>
    return -1;
80106a2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a32:	eb 32                	jmp    80106a66 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a37:	89 04 24             	mov    %eax,(%esp)
80106a3a:	e8 2f b7 ff ff       	call   8010216e <iunlock>
  iput(proc->cwd);
80106a3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a45:	8b 40 68             	mov    0x68(%eax),%eax
80106a48:	89 04 24             	mov    %eax,(%esp)
80106a4b:	e8 83 b7 ff ff       	call   801021d3 <iput>
  end_op();
80106a50:	e8 31 d2 ff ff       	call   80103c86 <end_op>
  proc->cwd = ip;
80106a55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a5e:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106a61:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a66:	c9                   	leave  
80106a67:	c3                   	ret    

80106a68 <sys_exec>:

int
sys_exec(void)
{
80106a68:	55                   	push   %ebp
80106a69:	89 e5                	mov    %esp,%ebp
80106a6b:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106a71:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a74:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a7f:	e8 7c f3 ff ff       	call   80105e00 <argstr>
80106a84:	85 c0                	test   %eax,%eax
80106a86:	78 1a                	js     80106aa2 <sys_exec+0x3a>
80106a88:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a92:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a99:	e8 d2 f2 ff ff       	call   80105d70 <argint>
80106a9e:	85 c0                	test   %eax,%eax
80106aa0:	79 0a                	jns    80106aac <sys_exec+0x44>
    return -1;
80106aa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aa7:	e9 c8 00 00 00       	jmp    80106b74 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
80106aac:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106ab3:	00 
80106ab4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106abb:	00 
80106abc:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106ac2:	89 04 24             	mov    %eax,(%esp)
80106ac5:	e8 64 ef ff ff       	call   80105a2e <memset>
  for(i=0;; i++){
80106aca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad4:	83 f8 1f             	cmp    $0x1f,%eax
80106ad7:	76 0a                	jbe    80106ae3 <sys_exec+0x7b>
      return -1;
80106ad9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ade:	e9 91 00 00 00       	jmp    80106b74 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae6:	c1 e0 02             	shl    $0x2,%eax
80106ae9:	89 c2                	mov    %eax,%edx
80106aeb:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106af1:	01 c2                	add    %eax,%edx
80106af3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106af9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106afd:	89 14 24             	mov    %edx,(%esp)
80106b00:	e8 cf f1 ff ff       	call   80105cd4 <fetchint>
80106b05:	85 c0                	test   %eax,%eax
80106b07:	79 07                	jns    80106b10 <sys_exec+0xa8>
      return -1;
80106b09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b0e:	eb 64                	jmp    80106b74 <sys_exec+0x10c>
    if(uarg == 0){
80106b10:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106b16:	85 c0                	test   %eax,%eax
80106b18:	75 26                	jne    80106b40 <sys_exec+0xd8>
      argv[i] = 0;
80106b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b1d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106b24:	00 00 00 00 
      break;
80106b28:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b2c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106b32:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b36:	89 04 24             	mov    %eax,(%esp)
80106b39:	e8 12 a7 ff ff       	call   80101250 <exec>
80106b3e:	eb 34                	jmp    80106b74 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106b40:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b49:	c1 e2 02             	shl    $0x2,%edx
80106b4c:	01 c2                	add    %eax,%edx
80106b4e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106b54:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b58:	89 04 24             	mov    %eax,(%esp)
80106b5b:	e8 ae f1 ff ff       	call   80105d0e <fetchstr>
80106b60:	85 c0                	test   %eax,%eax
80106b62:	79 07                	jns    80106b6b <sys_exec+0x103>
      return -1;
80106b64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b69:	eb 09                	jmp    80106b74 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106b6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106b6f:	e9 5d ff ff ff       	jmp    80106ad1 <sys_exec+0x69>
  return exec(path, argv);
}
80106b74:	c9                   	leave  
80106b75:	c3                   	ret    

80106b76 <sys_pipe>:

int
sys_pipe(void)
{
80106b76:	55                   	push   %ebp
80106b77:	89 e5                	mov    %esp,%ebp
80106b79:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106b7c:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106b83:	00 
80106b84:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106b87:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b92:	e8 07 f2 ff ff       	call   80105d9e <argptr>
80106b97:	85 c0                	test   %eax,%eax
80106b99:	79 0a                	jns    80106ba5 <sys_pipe+0x2f>
    return -1;
80106b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ba0:	e9 9b 00 00 00       	jmp    80106c40 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106ba5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bac:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106baf:	89 04 24             	mov    %eax,(%esp)
80106bb2:	e8 57 db ff ff       	call   8010470e <pipealloc>
80106bb7:	85 c0                	test   %eax,%eax
80106bb9:	79 07                	jns    80106bc2 <sys_pipe+0x4c>
    return -1;
80106bbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bc0:	eb 7e                	jmp    80106c40 <sys_pipe+0xca>
  fd0 = -1;
80106bc2:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106bc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106bcc:	89 04 24             	mov    %eax,(%esp)
80106bcf:	e8 67 f3 ff ff       	call   80105f3b <fdalloc>
80106bd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106bd7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bdb:	78 14                	js     80106bf1 <sys_pipe+0x7b>
80106bdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106be0:	89 04 24             	mov    %eax,(%esp)
80106be3:	e8 53 f3 ff ff       	call   80105f3b <fdalloc>
80106be8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106beb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106bef:	79 37                	jns    80106c28 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106bf1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bf5:	78 14                	js     80106c0b <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106bf7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c00:	83 c2 08             	add    $0x8,%edx
80106c03:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106c0a:	00 
    fileclose(rf);
80106c0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c0e:	89 04 24             	mov    %eax,(%esp)
80106c11:	e8 19 ab ff ff       	call   8010172f <fileclose>
    fileclose(wf);
80106c16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c19:	89 04 24             	mov    %eax,(%esp)
80106c1c:	e8 0e ab ff ff       	call   8010172f <fileclose>
    return -1;
80106c21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c26:	eb 18                	jmp    80106c40 <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106c28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c2e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106c30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c33:	8d 50 04             	lea    0x4(%eax),%edx
80106c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c39:	89 02                	mov    %eax,(%edx)
  return 0;
80106c3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c40:	c9                   	leave  
80106c41:	c3                   	ret    

80106c42 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106c42:	55                   	push   %ebp
80106c43:	89 e5                	mov    %esp,%ebp
80106c45:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106c48:	e8 6f e1 ff ff       	call   80104dbc <fork>
}
80106c4d:	c9                   	leave  
80106c4e:	c3                   	ret    

80106c4f <sys_exit>:

int
sys_exit(void)
{
80106c4f:	55                   	push   %ebp
80106c50:	89 e5                	mov    %esp,%ebp
80106c52:	83 ec 08             	sub    $0x8,%esp
  exit();
80106c55:	e8 ea e2 ff ff       	call   80104f44 <exit>
  return 0;  // not reached
80106c5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106c5f:	c9                   	leave  
80106c60:	c3                   	ret    

80106c61 <sys_wait>:

int
sys_wait(void)
{
80106c61:	55                   	push   %ebp
80106c62:	89 e5                	mov    %esp,%ebp
80106c64:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106c67:	e8 fd e3 ff ff       	call   80105069 <wait>
}
80106c6c:	c9                   	leave  
80106c6d:	c3                   	ret    

80106c6e <sys_kill>:

int
sys_kill(void)
{
80106c6e:	55                   	push   %ebp
80106c6f:	89 e5                	mov    %esp,%ebp
80106c71:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106c74:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c77:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c82:	e8 e9 f0 ff ff       	call   80105d70 <argint>
80106c87:	85 c0                	test   %eax,%eax
80106c89:	79 07                	jns    80106c92 <sys_kill+0x24>
    return -1;
80106c8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c90:	eb 0b                	jmp    80106c9d <sys_kill+0x2f>
  return kill(pid);
80106c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c95:	89 04 24             	mov    %eax,(%esp)
80106c98:	e8 f5 e8 ff ff       	call   80105592 <kill>
}
80106c9d:	c9                   	leave  
80106c9e:	c3                   	ret    

80106c9f <sys_getpid>:

int
sys_getpid(void)
{
80106c9f:	55                   	push   %ebp
80106ca0:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106ca2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ca8:	8b 40 10             	mov    0x10(%eax),%eax
}
80106cab:	5d                   	pop    %ebp
80106cac:	c3                   	ret    

80106cad <sys_sbrk>:

int
sys_sbrk(void)
{
80106cad:	55                   	push   %ebp
80106cae:	89 e5                	mov    %esp,%ebp
80106cb0:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106cb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cc1:	e8 aa f0 ff ff       	call   80105d70 <argint>
80106cc6:	85 c0                	test   %eax,%eax
80106cc8:	79 07                	jns    80106cd1 <sys_sbrk+0x24>
    return -1;
80106cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ccf:	eb 24                	jmp    80106cf5 <sys_sbrk+0x48>
  addr = proc->sz;
80106cd1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cd7:	8b 00                	mov    (%eax),%eax
80106cd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106cdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cdf:	89 04 24             	mov    %eax,(%esp)
80106ce2:	e8 30 e0 ff ff       	call   80104d17 <growproc>
80106ce7:	85 c0                	test   %eax,%eax
80106ce9:	79 07                	jns    80106cf2 <sys_sbrk+0x45>
    return -1;
80106ceb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cf0:	eb 03                	jmp    80106cf5 <sys_sbrk+0x48>
  return addr;
80106cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106cf5:	c9                   	leave  
80106cf6:	c3                   	ret    

80106cf7 <sys_sleep>:

int
sys_sleep(void)
{
80106cf7:	55                   	push   %ebp
80106cf8:	89 e5                	mov    %esp,%ebp
80106cfa:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106cfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d00:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d0b:	e8 60 f0 ff ff       	call   80105d70 <argint>
80106d10:	85 c0                	test   %eax,%eax
80106d12:	79 07                	jns    80106d1b <sys_sleep+0x24>
    return -1;
80106d14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d19:	eb 6c                	jmp    80106d87 <sys_sleep+0x90>
  acquire(&tickslock);
80106d1b:	c7 04 24 c0 64 11 80 	movl   $0x801164c0,(%esp)
80106d22:	e8 b3 ea ff ff       	call   801057da <acquire>
  ticks0 = ticks;
80106d27:	a1 00 6d 11 80       	mov    0x80116d00,%eax
80106d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106d2f:	eb 34                	jmp    80106d65 <sys_sleep+0x6e>
    if(proc->killed){
80106d31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d37:	8b 40 24             	mov    0x24(%eax),%eax
80106d3a:	85 c0                	test   %eax,%eax
80106d3c:	74 13                	je     80106d51 <sys_sleep+0x5a>
      release(&tickslock);
80106d3e:	c7 04 24 c0 64 11 80 	movl   $0x801164c0,(%esp)
80106d45:	e8 f2 ea ff ff       	call   8010583c <release>
      return -1;
80106d4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d4f:	eb 36                	jmp    80106d87 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106d51:	c7 44 24 04 c0 64 11 	movl   $0x801164c0,0x4(%esp)
80106d58:	80 
80106d59:	c7 04 24 00 6d 11 80 	movl   $0x80116d00,(%esp)
80106d60:	e8 26 e7 ff ff       	call   8010548b <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106d65:	a1 00 6d 11 80       	mov    0x80116d00,%eax
80106d6a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106d6d:	89 c2                	mov    %eax,%edx
80106d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d72:	39 c2                	cmp    %eax,%edx
80106d74:	72 bb                	jb     80106d31 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106d76:	c7 04 24 c0 64 11 80 	movl   $0x801164c0,(%esp)
80106d7d:	e8 ba ea ff ff       	call   8010583c <release>
  return 0;
80106d82:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d87:	c9                   	leave  
80106d88:	c3                   	ret    

80106d89 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106d89:	55                   	push   %ebp
80106d8a:	89 e5                	mov    %esp,%ebp
80106d8c:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106d8f:	c7 04 24 c0 64 11 80 	movl   $0x801164c0,(%esp)
80106d96:	e8 3f ea ff ff       	call   801057da <acquire>
  xticks = ticks;
80106d9b:	a1 00 6d 11 80       	mov    0x80116d00,%eax
80106da0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106da3:	c7 04 24 c0 64 11 80 	movl   $0x801164c0,(%esp)
80106daa:	e8 8d ea ff ff       	call   8010583c <release>
  return xticks;
80106daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106db2:	c9                   	leave  
80106db3:	c3                   	ret    

80106db4 <sys_wait2>:

int
sys_wait2(void)
{
80106db4:	55                   	push   %ebp
80106db5:	89 e5                	mov    %esp,%ebp
80106db7:	83 ec 28             	sub    $0x28,%esp
  int* retime;
  int* rutime;
  int* stime;
  if(argptr(0, (void*)&retime,sizeof(*retime)) < 0)
80106dba:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106dc1:	00 
80106dc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106dd0:	e8 c9 ef ff ff       	call   80105d9e <argptr>
80106dd5:	85 c0                	test   %eax,%eax
80106dd7:	79 07                	jns    80106de0 <sys_wait2+0x2c>
    return -1;
80106dd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dde:	eb 65                	jmp    80106e45 <sys_wait2+0x91>
  if(argptr(1, (void*)&rutime,sizeof(*rutime)) < 0)
80106de0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106de7:	00 
80106de8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106deb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106def:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106df6:	e8 a3 ef ff ff       	call   80105d9e <argptr>
80106dfb:	85 c0                	test   %eax,%eax
80106dfd:	79 07                	jns    80106e06 <sys_wait2+0x52>
    return -1;
80106dff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e04:	eb 3f                	jmp    80106e45 <sys_wait2+0x91>
  if(argptr(2, (void*)&stime,sizeof(*stime)) < 0)
80106e06:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106e0d:	00 
80106e0e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e11:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e15:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106e1c:	e8 7d ef ff ff       	call   80105d9e <argptr>
80106e21:	85 c0                	test   %eax,%eax
80106e23:	79 07                	jns    80106e2c <sys_wait2+0x78>
    return -1;
80106e25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e2a:	eb 19                	jmp    80106e45 <sys_wait2+0x91>
  return wait2(retime,rutime,stime);
80106e2c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106e2f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e35:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106e39:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e3d:	89 04 24             	mov    %eax,(%esp)
80106e40:	e8 36 e3 ff ff       	call   8010517b <wait2>
}
80106e45:	c9                   	leave  
80106e46:	c3                   	ret    

80106e47 <sys_history>:

int history(char*,int);
int sys_history(void){
80106e47:	55                   	push   %ebp
80106e48:	89 e5                	mov    %esp,%ebp
80106e4a:	57                   	push   %edi
80106e4b:	53                   	push   %ebx
80106e4c:	81 ec a0 00 00 00    	sub    $0xa0,%esp
  char str[128]="";
80106e52:	c7 85 70 ff ff ff 00 	movl   $0x0,-0x90(%ebp)
80106e59:	00 00 00 
80106e5c:	8d 9d 74 ff ff ff    	lea    -0x8c(%ebp),%ebx
80106e62:	b8 00 00 00 00       	mov    $0x0,%eax
80106e67:	ba 1f 00 00 00       	mov    $0x1f,%edx
80106e6c:	89 df                	mov    %ebx,%edi
80106e6e:	89 d1                	mov    %edx,%ecx
80106e70:	f3 ab                	rep stos %eax,%es:(%edi)
  int i = 0;
80106e72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int k;
  while((k=history(str,i)) > -1){
80106e79:	eb 42                	jmp    80106ebd <sys_history+0x76>
    cprintf("%d)   %s\n",i+1,str);
80106e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e7e:	8d 50 01             	lea    0x1(%eax),%edx
80106e81:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106e87:	89 44 24 08          	mov    %eax,0x8(%esp)
80106e8b:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e8f:	c7 04 24 ae 93 10 80 	movl   $0x801093ae,(%esp)
80106e96:	e8 05 95 ff ff       	call   801003a0 <cprintf>
    memset(str,0,128);
80106e9b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106ea2:	00 
80106ea3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106eaa:	00 
80106eab:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106eb1:	89 04 24             	mov    %eax,(%esp)
80106eb4:	e8 75 eb ff ff       	call   80105a2e <memset>
    i++;
80106eb9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
int history(char*,int);
int sys_history(void){
  char str[128]="";
  int i = 0;
  int k;
  while((k=history(str,i)) > -1){
80106ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ec0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ec4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106eca:	89 04 24             	mov    %eax,(%esp)
80106ecd:	e8 ad 97 ff ff       	call   8010067f <history>
80106ed2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ed5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ed9:	79 a0                	jns    80106e7b <sys_history+0x34>
    cprintf("%d)   %s\n",i+1,str);
    memset(str,0,128);
    i++;
  }
  return 0;
80106edb:	b8 00 00 00 00       	mov    $0x0,%eax
80106ee0:	81 c4 a0 00 00 00    	add    $0xa0,%esp
80106ee6:	5b                   	pop    %ebx
80106ee7:	5f                   	pop    %edi
80106ee8:	5d                   	pop    %ebp
80106ee9:	c3                   	ret    

80106eea <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106eea:	55                   	push   %ebp
80106eeb:	89 e5                	mov    %esp,%ebp
80106eed:	83 ec 08             	sub    $0x8,%esp
80106ef0:	8b 55 08             	mov    0x8(%ebp),%edx
80106ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ef6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106efa:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106efd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f01:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f05:	ee                   	out    %al,(%dx)
}
80106f06:	c9                   	leave  
80106f07:	c3                   	ret    

80106f08 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106f08:	55                   	push   %ebp
80106f09:	89 e5                	mov    %esp,%ebp
80106f0b:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106f0e:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106f15:	00 
80106f16:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106f1d:	e8 c8 ff ff ff       	call   80106eea <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106f22:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106f29:	00 
80106f2a:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106f31:	e8 b4 ff ff ff       	call   80106eea <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106f36:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106f3d:	00 
80106f3e:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106f45:	e8 a0 ff ff ff       	call   80106eea <outb>
  picenable(IRQ_TIMER);
80106f4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f51:	e8 4b d6 ff ff       	call   801045a1 <picenable>
}
80106f56:	c9                   	leave  
80106f57:	c3                   	ret    

80106f58 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106f58:	1e                   	push   %ds
  pushl %es
80106f59:	06                   	push   %es
  pushl %fs
80106f5a:	0f a0                	push   %fs
  pushl %gs
80106f5c:	0f a8                	push   %gs
  pushal
80106f5e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106f5f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106f63:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106f65:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106f67:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106f6b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106f6d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106f6f:	54                   	push   %esp
  call trap
80106f70:	e8 d8 01 00 00       	call   8010714d <trap>
  addl $4, %esp
80106f75:	83 c4 04             	add    $0x4,%esp

80106f78 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106f78:	61                   	popa   
  popl %gs
80106f79:	0f a9                	pop    %gs
  popl %fs
80106f7b:	0f a1                	pop    %fs
  popl %es
80106f7d:	07                   	pop    %es
  popl %ds
80106f7e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106f7f:	83 c4 08             	add    $0x8,%esp
  iret
80106f82:	cf                   	iret   

80106f83 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106f83:	55                   	push   %ebp
80106f84:	89 e5                	mov    %esp,%ebp
80106f86:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106f89:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f8c:	83 e8 01             	sub    $0x1,%eax
80106f8f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106f93:	8b 45 08             	mov    0x8(%ebp),%eax
80106f96:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80106f9d:	c1 e8 10             	shr    $0x10,%eax
80106fa0:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106fa4:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106fa7:	0f 01 18             	lidtl  (%eax)
}
80106faa:	c9                   	leave  
80106fab:	c3                   	ret    

80106fac <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106fac:	55                   	push   %ebp
80106fad:	89 e5                	mov    %esp,%ebp
80106faf:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106fb2:	0f 20 d0             	mov    %cr2,%eax
80106fb5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106fb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106fbb:	c9                   	leave  
80106fbc:	c3                   	ret    

80106fbd <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106fbd:	55                   	push   %ebp
80106fbe:	89 e5                	mov    %esp,%ebp
80106fc0:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106fc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106fca:	e9 c3 00 00 00       	jmp    80107092 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd2:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
80106fd9:	89 c2                	mov    %eax,%edx
80106fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fde:	66 89 14 c5 00 65 11 	mov    %dx,-0x7fee9b00(,%eax,8)
80106fe5:	80 
80106fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fe9:	66 c7 04 c5 02 65 11 	movw   $0x8,-0x7fee9afe(,%eax,8)
80106ff0:	80 08 00 
80106ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff6:	0f b6 14 c5 04 65 11 	movzbl -0x7fee9afc(,%eax,8),%edx
80106ffd:	80 
80106ffe:	83 e2 e0             	and    $0xffffffe0,%edx
80107001:	88 14 c5 04 65 11 80 	mov    %dl,-0x7fee9afc(,%eax,8)
80107008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010700b:	0f b6 14 c5 04 65 11 	movzbl -0x7fee9afc(,%eax,8),%edx
80107012:	80 
80107013:	83 e2 1f             	and    $0x1f,%edx
80107016:	88 14 c5 04 65 11 80 	mov    %dl,-0x7fee9afc(,%eax,8)
8010701d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107020:	0f b6 14 c5 05 65 11 	movzbl -0x7fee9afb(,%eax,8),%edx
80107027:	80 
80107028:	83 e2 f0             	and    $0xfffffff0,%edx
8010702b:	83 ca 0e             	or     $0xe,%edx
8010702e:	88 14 c5 05 65 11 80 	mov    %dl,-0x7fee9afb(,%eax,8)
80107035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107038:	0f b6 14 c5 05 65 11 	movzbl -0x7fee9afb(,%eax,8),%edx
8010703f:	80 
80107040:	83 e2 ef             	and    $0xffffffef,%edx
80107043:	88 14 c5 05 65 11 80 	mov    %dl,-0x7fee9afb(,%eax,8)
8010704a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010704d:	0f b6 14 c5 05 65 11 	movzbl -0x7fee9afb(,%eax,8),%edx
80107054:	80 
80107055:	83 e2 9f             	and    $0xffffff9f,%edx
80107058:	88 14 c5 05 65 11 80 	mov    %dl,-0x7fee9afb(,%eax,8)
8010705f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107062:	0f b6 14 c5 05 65 11 	movzbl -0x7fee9afb(,%eax,8),%edx
80107069:	80 
8010706a:	83 ca 80             	or     $0xffffff80,%edx
8010706d:	88 14 c5 05 65 11 80 	mov    %dl,-0x7fee9afb(,%eax,8)
80107074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107077:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
8010707e:	c1 e8 10             	shr    $0x10,%eax
80107081:	89 c2                	mov    %eax,%edx
80107083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107086:	66 89 14 c5 06 65 11 	mov    %dx,-0x7fee9afa(,%eax,8)
8010708d:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010708e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107092:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107099:	0f 8e 30 ff ff ff    	jle    80106fcf <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010709f:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
801070a4:	66 a3 00 67 11 80    	mov    %ax,0x80116700
801070aa:	66 c7 05 02 67 11 80 	movw   $0x8,0x80116702
801070b1:	08 00 
801070b3:	0f b6 05 04 67 11 80 	movzbl 0x80116704,%eax
801070ba:	83 e0 e0             	and    $0xffffffe0,%eax
801070bd:	a2 04 67 11 80       	mov    %al,0x80116704
801070c2:	0f b6 05 04 67 11 80 	movzbl 0x80116704,%eax
801070c9:	83 e0 1f             	and    $0x1f,%eax
801070cc:	a2 04 67 11 80       	mov    %al,0x80116704
801070d1:	0f b6 05 05 67 11 80 	movzbl 0x80116705,%eax
801070d8:	83 c8 0f             	or     $0xf,%eax
801070db:	a2 05 67 11 80       	mov    %al,0x80116705
801070e0:	0f b6 05 05 67 11 80 	movzbl 0x80116705,%eax
801070e7:	83 e0 ef             	and    $0xffffffef,%eax
801070ea:	a2 05 67 11 80       	mov    %al,0x80116705
801070ef:	0f b6 05 05 67 11 80 	movzbl 0x80116705,%eax
801070f6:	83 c8 60             	or     $0x60,%eax
801070f9:	a2 05 67 11 80       	mov    %al,0x80116705
801070fe:	0f b6 05 05 67 11 80 	movzbl 0x80116705,%eax
80107105:	83 c8 80             	or     $0xffffff80,%eax
80107108:	a2 05 67 11 80       	mov    %al,0x80116705
8010710d:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
80107112:	c1 e8 10             	shr    $0x10,%eax
80107115:	66 a3 06 67 11 80    	mov    %ax,0x80116706
  
  initlock(&tickslock, "time");
8010711b:	c7 44 24 04 b8 93 10 	movl   $0x801093b8,0x4(%esp)
80107122:	80 
80107123:	c7 04 24 c0 64 11 80 	movl   $0x801164c0,(%esp)
8010712a:	e8 8a e6 ff ff       	call   801057b9 <initlock>
}
8010712f:	c9                   	leave  
80107130:	c3                   	ret    

80107131 <idtinit>:

void
idtinit(void)
{
80107131:	55                   	push   %ebp
80107132:	89 e5                	mov    %esp,%ebp
80107134:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80107137:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
8010713e:	00 
8010713f:	c7 04 24 00 65 11 80 	movl   $0x80116500,(%esp)
80107146:	e8 38 fe ff ff       	call   80106f83 <lidt>
}
8010714b:	c9                   	leave  
8010714c:	c3                   	ret    

8010714d <trap>:
void update_statistics(void);

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010714d:	55                   	push   %ebp
8010714e:	89 e5                	mov    %esp,%ebp
80107150:	57                   	push   %edi
80107151:	56                   	push   %esi
80107152:	53                   	push   %ebx
80107153:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80107156:	8b 45 08             	mov    0x8(%ebp),%eax
80107159:	8b 40 30             	mov    0x30(%eax),%eax
8010715c:	83 f8 40             	cmp    $0x40,%eax
8010715f:	75 3f                	jne    801071a0 <trap+0x53>
    if(proc->killed)
80107161:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107167:	8b 40 24             	mov    0x24(%eax),%eax
8010716a:	85 c0                	test   %eax,%eax
8010716c:	74 05                	je     80107173 <trap+0x26>
      exit();
8010716e:	e8 d1 dd ff ff       	call   80104f44 <exit>
    proc->tf = tf;
80107173:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107179:	8b 55 08             	mov    0x8(%ebp),%edx
8010717c:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010717f:	e8 b3 ec ff ff       	call   80105e37 <syscall>
    if(proc->killed)
80107184:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010718a:	8b 40 24             	mov    0x24(%eax),%eax
8010718d:	85 c0                	test   %eax,%eax
8010718f:	74 0a                	je     8010719b <trap+0x4e>
      exit();
80107191:	e8 ae dd ff ff       	call   80104f44 <exit>
    return;
80107196:	e9 32 02 00 00       	jmp    801073cd <trap+0x280>
8010719b:	e9 2d 02 00 00       	jmp    801073cd <trap+0x280>
  }
  

  switch(tf->trapno){
801071a0:	8b 45 08             	mov    0x8(%ebp),%eax
801071a3:	8b 40 30             	mov    0x30(%eax),%eax
801071a6:	83 e8 20             	sub    $0x20,%eax
801071a9:	83 f8 1f             	cmp    $0x1f,%eax
801071ac:	0f 87 c1 00 00 00    	ja     80107273 <trap+0x126>
801071b2:	8b 04 85 60 94 10 80 	mov    -0x7fef6ba0(,%eax,4),%eax
801071b9:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801071bb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801071c1:	0f b6 00             	movzbl (%eax),%eax
801071c4:	84 c0                	test   %al,%al
801071c6:	75 36                	jne    801071fe <trap+0xb1>
      acquire(&tickslock);
801071c8:	c7 04 24 c0 64 11 80 	movl   $0x801164c0,(%esp)
801071cf:	e8 06 e6 ff ff       	call   801057da <acquire>
      ticks++;
801071d4:	a1 00 6d 11 80       	mov    0x80116d00,%eax
801071d9:	83 c0 01             	add    $0x1,%eax
801071dc:	a3 00 6d 11 80       	mov    %eax,0x80116d00
      update_statistics();
801071e1:	e8 21 e5 ff ff       	call   80105707 <update_statistics>
      wakeup(&ticks);
801071e6:	c7 04 24 00 6d 11 80 	movl   $0x80116d00,(%esp)
801071ed:	e8 75 e3 ff ff       	call   80105567 <wakeup>
      release(&tickslock);
801071f2:	c7 04 24 c0 64 11 80 	movl   $0x801164c0,(%esp)
801071f9:	e8 3e e6 ff ff       	call   8010583c <release>
    }
    lapiceoi();
801071fe:	e8 c9 c4 ff ff       	call   801036cc <lapiceoi>
    break;
80107203:	e9 41 01 00 00       	jmp    80107349 <trap+0x1fc>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107208:	e8 cd bc ff ff       	call   80102eda <ideintr>
    lapiceoi();
8010720d:	e8 ba c4 ff ff       	call   801036cc <lapiceoi>
    break;
80107212:	e9 32 01 00 00       	jmp    80107349 <trap+0x1fc>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107217:	e8 7f c2 ff ff       	call   8010349b <kbdintr>
    lapiceoi();
8010721c:	e8 ab c4 ff ff       	call   801036cc <lapiceoi>
    break;
80107221:	e9 23 01 00 00       	jmp    80107349 <trap+0x1fc>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107226:	e8 97 03 00 00       	call   801075c2 <uartintr>
    lapiceoi();
8010722b:	e8 9c c4 ff ff       	call   801036cc <lapiceoi>
    break;
80107230:	e9 14 01 00 00       	jmp    80107349 <trap+0x1fc>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107235:	8b 45 08             	mov    0x8(%ebp),%eax
80107238:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010723b:	8b 45 08             	mov    0x8(%ebp),%eax
8010723e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107242:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107245:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010724b:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010724e:	0f b6 c0             	movzbl %al,%eax
80107251:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80107255:	89 54 24 08          	mov    %edx,0x8(%esp)
80107259:	89 44 24 04          	mov    %eax,0x4(%esp)
8010725d:	c7 04 24 c0 93 10 80 	movl   $0x801093c0,(%esp)
80107264:	e8 37 91 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107269:	e8 5e c4 ff ff       	call   801036cc <lapiceoi>
    break;
8010726e:	e9 d6 00 00 00       	jmp    80107349 <trap+0x1fc>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107273:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107279:	85 c0                	test   %eax,%eax
8010727b:	74 11                	je     8010728e <trap+0x141>
8010727d:	8b 45 08             	mov    0x8(%ebp),%eax
80107280:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107284:	0f b7 c0             	movzwl %ax,%eax
80107287:	83 e0 03             	and    $0x3,%eax
8010728a:	85 c0                	test   %eax,%eax
8010728c:	75 46                	jne    801072d4 <trap+0x187>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010728e:	e8 19 fd ff ff       	call   80106fac <rcr2>
80107293:	8b 55 08             	mov    0x8(%ebp),%edx
80107296:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107299:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801072a0:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801072a3:	0f b6 ca             	movzbl %dl,%ecx
801072a6:	8b 55 08             	mov    0x8(%ebp),%edx
801072a9:	8b 52 30             	mov    0x30(%edx),%edx
801072ac:	89 44 24 10          	mov    %eax,0x10(%esp)
801072b0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801072b4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801072b8:	89 54 24 04          	mov    %edx,0x4(%esp)
801072bc:	c7 04 24 e4 93 10 80 	movl   $0x801093e4,(%esp)
801072c3:	e8 d8 90 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801072c8:	c7 04 24 16 94 10 80 	movl   $0x80109416,(%esp)
801072cf:	e8 66 92 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801072d4:	e8 d3 fc ff ff       	call   80106fac <rcr2>
801072d9:	89 c2                	mov    %eax,%edx
801072db:	8b 45 08             	mov    0x8(%ebp),%eax
801072de:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801072e1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801072e7:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801072ea:	0f b6 f0             	movzbl %al,%esi
801072ed:	8b 45 08             	mov    0x8(%ebp),%eax
801072f0:	8b 58 34             	mov    0x34(%eax),%ebx
801072f3:	8b 45 08             	mov    0x8(%ebp),%eax
801072f6:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801072f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072ff:	83 c0 6c             	add    $0x6c,%eax
80107302:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107305:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010730b:	8b 40 10             	mov    0x10(%eax),%eax
8010730e:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80107312:	89 7c 24 18          	mov    %edi,0x18(%esp)
80107316:	89 74 24 14          	mov    %esi,0x14(%esp)
8010731a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010731e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80107322:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80107325:	89 74 24 08          	mov    %esi,0x8(%esp)
80107329:	89 44 24 04          	mov    %eax,0x4(%esp)
8010732d:	c7 04 24 1c 94 10 80 	movl   $0x8010941c,(%esp)
80107334:	e8 67 90 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107339:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010733f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107346:	eb 01                	jmp    80107349 <trap+0x1fc>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107348:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107349:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010734f:	85 c0                	test   %eax,%eax
80107351:	74 24                	je     80107377 <trap+0x22a>
80107353:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107359:	8b 40 24             	mov    0x24(%eax),%eax
8010735c:	85 c0                	test   %eax,%eax
8010735e:	74 17                	je     80107377 <trap+0x22a>
80107360:	8b 45 08             	mov    0x8(%ebp),%eax
80107363:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107367:	0f b7 c0             	movzwl %ax,%eax
8010736a:	83 e0 03             	and    $0x3,%eax
8010736d:	83 f8 03             	cmp    $0x3,%eax
80107370:	75 05                	jne    80107377 <trap+0x22a>
    exit();
80107372:	e8 cd db ff ff       	call   80104f44 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80107377:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010737d:	85 c0                	test   %eax,%eax
8010737f:	74 1e                	je     8010739f <trap+0x252>
80107381:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107387:	8b 40 0c             	mov    0xc(%eax),%eax
8010738a:	83 f8 04             	cmp    $0x4,%eax
8010738d:	75 10                	jne    8010739f <trap+0x252>
8010738f:	8b 45 08             	mov    0x8(%ebp),%eax
80107392:	8b 40 30             	mov    0x30(%eax),%eax
80107395:	83 f8 20             	cmp    $0x20,%eax
80107398:	75 05                	jne    8010739f <trap+0x252>
    yield();
8010739a:	e8 7b e0 ff ff       	call   8010541a <yield>
  
  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010739f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073a5:	85 c0                	test   %eax,%eax
801073a7:	74 24                	je     801073cd <trap+0x280>
801073a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073af:	8b 40 24             	mov    0x24(%eax),%eax
801073b2:	85 c0                	test   %eax,%eax
801073b4:	74 17                	je     801073cd <trap+0x280>
801073b6:	8b 45 08             	mov    0x8(%ebp),%eax
801073b9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801073bd:	0f b7 c0             	movzwl %ax,%eax
801073c0:	83 e0 03             	and    $0x3,%eax
801073c3:	83 f8 03             	cmp    $0x3,%eax
801073c6:	75 05                	jne    801073cd <trap+0x280>
    exit();
801073c8:	e8 77 db ff ff       	call   80104f44 <exit>
}
801073cd:	83 c4 3c             	add    $0x3c,%esp
801073d0:	5b                   	pop    %ebx
801073d1:	5e                   	pop    %esi
801073d2:	5f                   	pop    %edi
801073d3:	5d                   	pop    %ebp
801073d4:	c3                   	ret    

801073d5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801073d5:	55                   	push   %ebp
801073d6:	89 e5                	mov    %esp,%ebp
801073d8:	83 ec 14             	sub    $0x14,%esp
801073db:	8b 45 08             	mov    0x8(%ebp),%eax
801073de:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801073e2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801073e6:	89 c2                	mov    %eax,%edx
801073e8:	ec                   	in     (%dx),%al
801073e9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801073ec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801073f0:	c9                   	leave  
801073f1:	c3                   	ret    

801073f2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801073f2:	55                   	push   %ebp
801073f3:	89 e5                	mov    %esp,%ebp
801073f5:	83 ec 08             	sub    $0x8,%esp
801073f8:	8b 55 08             	mov    0x8(%ebp),%edx
801073fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801073fe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107402:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107405:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107409:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010740d:	ee                   	out    %al,(%dx)
}
8010740e:	c9                   	leave  
8010740f:	c3                   	ret    

80107410 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107410:	55                   	push   %ebp
80107411:	89 e5                	mov    %esp,%ebp
80107413:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107416:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010741d:	00 
8010741e:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107425:	e8 c8 ff ff ff       	call   801073f2 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010742a:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107431:	00 
80107432:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107439:	e8 b4 ff ff ff       	call   801073f2 <outb>
  outb(COM1+0, 115200/9600);
8010743e:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107445:	00 
80107446:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010744d:	e8 a0 ff ff ff       	call   801073f2 <outb>
  outb(COM1+1, 0);
80107452:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107459:	00 
8010745a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107461:	e8 8c ff ff ff       	call   801073f2 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107466:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010746d:	00 
8010746e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107475:	e8 78 ff ff ff       	call   801073f2 <outb>
  outb(COM1+4, 0);
8010747a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107481:	00 
80107482:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107489:	e8 64 ff ff ff       	call   801073f2 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010748e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107495:	00 
80107496:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010749d:	e8 50 ff ff ff       	call   801073f2 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801074a2:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801074a9:	e8 27 ff ff ff       	call   801073d5 <inb>
801074ae:	3c ff                	cmp    $0xff,%al
801074b0:	75 02                	jne    801074b4 <uartinit+0xa4>
    return;
801074b2:	eb 6a                	jmp    8010751e <uartinit+0x10e>
  uart = 1;
801074b4:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
801074bb:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801074be:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801074c5:	e8 0b ff ff ff       	call   801073d5 <inb>
  inb(COM1+0);
801074ca:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801074d1:	e8 ff fe ff ff       	call   801073d5 <inb>
  picenable(IRQ_COM1);
801074d6:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801074dd:	e8 bf d0 ff ff       	call   801045a1 <picenable>
  ioapicenable(IRQ_COM1, 0);
801074e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801074e9:	00 
801074ea:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801074f1:	e8 63 bc ff ff       	call   80103159 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801074f6:	c7 45 f4 e0 94 10 80 	movl   $0x801094e0,-0xc(%ebp)
801074fd:	eb 15                	jmp    80107514 <uartinit+0x104>
    uartputc(*p);
801074ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107502:	0f b6 00             	movzbl (%eax),%eax
80107505:	0f be c0             	movsbl %al,%eax
80107508:	89 04 24             	mov    %eax,(%esp)
8010750b:	e8 10 00 00 00       	call   80107520 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107510:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107517:	0f b6 00             	movzbl (%eax),%eax
8010751a:	84 c0                	test   %al,%al
8010751c:	75 e1                	jne    801074ff <uartinit+0xef>
    uartputc(*p);
}
8010751e:	c9                   	leave  
8010751f:	c3                   	ret    

80107520 <uartputc>:

void
uartputc(int c)
{
80107520:	55                   	push   %ebp
80107521:	89 e5                	mov    %esp,%ebp
80107523:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107526:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
8010752b:	85 c0                	test   %eax,%eax
8010752d:	75 02                	jne    80107531 <uartputc+0x11>
    return;
8010752f:	eb 4b                	jmp    8010757c <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107531:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107538:	eb 10                	jmp    8010754a <uartputc+0x2a>
    microdelay(10);
8010753a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107541:	e8 ab c1 ff ff       	call   801036f1 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107546:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010754a:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010754e:	7f 16                	jg     80107566 <uartputc+0x46>
80107550:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107557:	e8 79 fe ff ff       	call   801073d5 <inb>
8010755c:	0f b6 c0             	movzbl %al,%eax
8010755f:	83 e0 20             	and    $0x20,%eax
80107562:	85 c0                	test   %eax,%eax
80107564:	74 d4                	je     8010753a <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107566:	8b 45 08             	mov    0x8(%ebp),%eax
80107569:	0f b6 c0             	movzbl %al,%eax
8010756c:	89 44 24 04          	mov    %eax,0x4(%esp)
80107570:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107577:	e8 76 fe ff ff       	call   801073f2 <outb>
}
8010757c:	c9                   	leave  
8010757d:	c3                   	ret    

8010757e <uartgetc>:

static int
uartgetc(void)
{
8010757e:	55                   	push   %ebp
8010757f:	89 e5                	mov    %esp,%ebp
80107581:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107584:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107589:	85 c0                	test   %eax,%eax
8010758b:	75 07                	jne    80107594 <uartgetc+0x16>
    return -1;
8010758d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107592:	eb 2c                	jmp    801075c0 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107594:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010759b:	e8 35 fe ff ff       	call   801073d5 <inb>
801075a0:	0f b6 c0             	movzbl %al,%eax
801075a3:	83 e0 01             	and    $0x1,%eax
801075a6:	85 c0                	test   %eax,%eax
801075a8:	75 07                	jne    801075b1 <uartgetc+0x33>
    return -1;
801075aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801075af:	eb 0f                	jmp    801075c0 <uartgetc+0x42>
  return inb(COM1+0);
801075b1:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801075b8:	e8 18 fe ff ff       	call   801073d5 <inb>
801075bd:	0f b6 c0             	movzbl %al,%eax
}
801075c0:	c9                   	leave  
801075c1:	c3                   	ret    

801075c2 <uartintr>:

void
uartintr(void)
{
801075c2:	55                   	push   %ebp
801075c3:	89 e5                	mov    %esp,%ebp
801075c5:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801075c8:	c7 04 24 7e 75 10 80 	movl   $0x8010757e,(%esp)
801075cf:	e8 f0 95 ff ff       	call   80100bc4 <consoleintr>
}
801075d4:	c9                   	leave  
801075d5:	c3                   	ret    

801075d6 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $0
801075d8:	6a 00                	push   $0x0
  jmp alltraps
801075da:	e9 79 f9 ff ff       	jmp    80106f58 <alltraps>

801075df <vector1>:
.globl vector1
vector1:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $1
801075e1:	6a 01                	push   $0x1
  jmp alltraps
801075e3:	e9 70 f9 ff ff       	jmp    80106f58 <alltraps>

801075e8 <vector2>:
.globl vector2
vector2:
  pushl $0
801075e8:	6a 00                	push   $0x0
  pushl $2
801075ea:	6a 02                	push   $0x2
  jmp alltraps
801075ec:	e9 67 f9 ff ff       	jmp    80106f58 <alltraps>

801075f1 <vector3>:
.globl vector3
vector3:
  pushl $0
801075f1:	6a 00                	push   $0x0
  pushl $3
801075f3:	6a 03                	push   $0x3
  jmp alltraps
801075f5:	e9 5e f9 ff ff       	jmp    80106f58 <alltraps>

801075fa <vector4>:
.globl vector4
vector4:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $4
801075fc:	6a 04                	push   $0x4
  jmp alltraps
801075fe:	e9 55 f9 ff ff       	jmp    80106f58 <alltraps>

80107603 <vector5>:
.globl vector5
vector5:
  pushl $0
80107603:	6a 00                	push   $0x0
  pushl $5
80107605:	6a 05                	push   $0x5
  jmp alltraps
80107607:	e9 4c f9 ff ff       	jmp    80106f58 <alltraps>

8010760c <vector6>:
.globl vector6
vector6:
  pushl $0
8010760c:	6a 00                	push   $0x0
  pushl $6
8010760e:	6a 06                	push   $0x6
  jmp alltraps
80107610:	e9 43 f9 ff ff       	jmp    80106f58 <alltraps>

80107615 <vector7>:
.globl vector7
vector7:
  pushl $0
80107615:	6a 00                	push   $0x0
  pushl $7
80107617:	6a 07                	push   $0x7
  jmp alltraps
80107619:	e9 3a f9 ff ff       	jmp    80106f58 <alltraps>

8010761e <vector8>:
.globl vector8
vector8:
  pushl $8
8010761e:	6a 08                	push   $0x8
  jmp alltraps
80107620:	e9 33 f9 ff ff       	jmp    80106f58 <alltraps>

80107625 <vector9>:
.globl vector9
vector9:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $9
80107627:	6a 09                	push   $0x9
  jmp alltraps
80107629:	e9 2a f9 ff ff       	jmp    80106f58 <alltraps>

8010762e <vector10>:
.globl vector10
vector10:
  pushl $10
8010762e:	6a 0a                	push   $0xa
  jmp alltraps
80107630:	e9 23 f9 ff ff       	jmp    80106f58 <alltraps>

80107635 <vector11>:
.globl vector11
vector11:
  pushl $11
80107635:	6a 0b                	push   $0xb
  jmp alltraps
80107637:	e9 1c f9 ff ff       	jmp    80106f58 <alltraps>

8010763c <vector12>:
.globl vector12
vector12:
  pushl $12
8010763c:	6a 0c                	push   $0xc
  jmp alltraps
8010763e:	e9 15 f9 ff ff       	jmp    80106f58 <alltraps>

80107643 <vector13>:
.globl vector13
vector13:
  pushl $13
80107643:	6a 0d                	push   $0xd
  jmp alltraps
80107645:	e9 0e f9 ff ff       	jmp    80106f58 <alltraps>

8010764a <vector14>:
.globl vector14
vector14:
  pushl $14
8010764a:	6a 0e                	push   $0xe
  jmp alltraps
8010764c:	e9 07 f9 ff ff       	jmp    80106f58 <alltraps>

80107651 <vector15>:
.globl vector15
vector15:
  pushl $0
80107651:	6a 00                	push   $0x0
  pushl $15
80107653:	6a 0f                	push   $0xf
  jmp alltraps
80107655:	e9 fe f8 ff ff       	jmp    80106f58 <alltraps>

8010765a <vector16>:
.globl vector16
vector16:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $16
8010765c:	6a 10                	push   $0x10
  jmp alltraps
8010765e:	e9 f5 f8 ff ff       	jmp    80106f58 <alltraps>

80107663 <vector17>:
.globl vector17
vector17:
  pushl $17
80107663:	6a 11                	push   $0x11
  jmp alltraps
80107665:	e9 ee f8 ff ff       	jmp    80106f58 <alltraps>

8010766a <vector18>:
.globl vector18
vector18:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $18
8010766c:	6a 12                	push   $0x12
  jmp alltraps
8010766e:	e9 e5 f8 ff ff       	jmp    80106f58 <alltraps>

80107673 <vector19>:
.globl vector19
vector19:
  pushl $0
80107673:	6a 00                	push   $0x0
  pushl $19
80107675:	6a 13                	push   $0x13
  jmp alltraps
80107677:	e9 dc f8 ff ff       	jmp    80106f58 <alltraps>

8010767c <vector20>:
.globl vector20
vector20:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $20
8010767e:	6a 14                	push   $0x14
  jmp alltraps
80107680:	e9 d3 f8 ff ff       	jmp    80106f58 <alltraps>

80107685 <vector21>:
.globl vector21
vector21:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $21
80107687:	6a 15                	push   $0x15
  jmp alltraps
80107689:	e9 ca f8 ff ff       	jmp    80106f58 <alltraps>

8010768e <vector22>:
.globl vector22
vector22:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $22
80107690:	6a 16                	push   $0x16
  jmp alltraps
80107692:	e9 c1 f8 ff ff       	jmp    80106f58 <alltraps>

80107697 <vector23>:
.globl vector23
vector23:
  pushl $0
80107697:	6a 00                	push   $0x0
  pushl $23
80107699:	6a 17                	push   $0x17
  jmp alltraps
8010769b:	e9 b8 f8 ff ff       	jmp    80106f58 <alltraps>

801076a0 <vector24>:
.globl vector24
vector24:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $24
801076a2:	6a 18                	push   $0x18
  jmp alltraps
801076a4:	e9 af f8 ff ff       	jmp    80106f58 <alltraps>

801076a9 <vector25>:
.globl vector25
vector25:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $25
801076ab:	6a 19                	push   $0x19
  jmp alltraps
801076ad:	e9 a6 f8 ff ff       	jmp    80106f58 <alltraps>

801076b2 <vector26>:
.globl vector26
vector26:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $26
801076b4:	6a 1a                	push   $0x1a
  jmp alltraps
801076b6:	e9 9d f8 ff ff       	jmp    80106f58 <alltraps>

801076bb <vector27>:
.globl vector27
vector27:
  pushl $0
801076bb:	6a 00                	push   $0x0
  pushl $27
801076bd:	6a 1b                	push   $0x1b
  jmp alltraps
801076bf:	e9 94 f8 ff ff       	jmp    80106f58 <alltraps>

801076c4 <vector28>:
.globl vector28
vector28:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $28
801076c6:	6a 1c                	push   $0x1c
  jmp alltraps
801076c8:	e9 8b f8 ff ff       	jmp    80106f58 <alltraps>

801076cd <vector29>:
.globl vector29
vector29:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $29
801076cf:	6a 1d                	push   $0x1d
  jmp alltraps
801076d1:	e9 82 f8 ff ff       	jmp    80106f58 <alltraps>

801076d6 <vector30>:
.globl vector30
vector30:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $30
801076d8:	6a 1e                	push   $0x1e
  jmp alltraps
801076da:	e9 79 f8 ff ff       	jmp    80106f58 <alltraps>

801076df <vector31>:
.globl vector31
vector31:
  pushl $0
801076df:	6a 00                	push   $0x0
  pushl $31
801076e1:	6a 1f                	push   $0x1f
  jmp alltraps
801076e3:	e9 70 f8 ff ff       	jmp    80106f58 <alltraps>

801076e8 <vector32>:
.globl vector32
vector32:
  pushl $0
801076e8:	6a 00                	push   $0x0
  pushl $32
801076ea:	6a 20                	push   $0x20
  jmp alltraps
801076ec:	e9 67 f8 ff ff       	jmp    80106f58 <alltraps>

801076f1 <vector33>:
.globl vector33
vector33:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $33
801076f3:	6a 21                	push   $0x21
  jmp alltraps
801076f5:	e9 5e f8 ff ff       	jmp    80106f58 <alltraps>

801076fa <vector34>:
.globl vector34
vector34:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $34
801076fc:	6a 22                	push   $0x22
  jmp alltraps
801076fe:	e9 55 f8 ff ff       	jmp    80106f58 <alltraps>

80107703 <vector35>:
.globl vector35
vector35:
  pushl $0
80107703:	6a 00                	push   $0x0
  pushl $35
80107705:	6a 23                	push   $0x23
  jmp alltraps
80107707:	e9 4c f8 ff ff       	jmp    80106f58 <alltraps>

8010770c <vector36>:
.globl vector36
vector36:
  pushl $0
8010770c:	6a 00                	push   $0x0
  pushl $36
8010770e:	6a 24                	push   $0x24
  jmp alltraps
80107710:	e9 43 f8 ff ff       	jmp    80106f58 <alltraps>

80107715 <vector37>:
.globl vector37
vector37:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $37
80107717:	6a 25                	push   $0x25
  jmp alltraps
80107719:	e9 3a f8 ff ff       	jmp    80106f58 <alltraps>

8010771e <vector38>:
.globl vector38
vector38:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $38
80107720:	6a 26                	push   $0x26
  jmp alltraps
80107722:	e9 31 f8 ff ff       	jmp    80106f58 <alltraps>

80107727 <vector39>:
.globl vector39
vector39:
  pushl $0
80107727:	6a 00                	push   $0x0
  pushl $39
80107729:	6a 27                	push   $0x27
  jmp alltraps
8010772b:	e9 28 f8 ff ff       	jmp    80106f58 <alltraps>

80107730 <vector40>:
.globl vector40
vector40:
  pushl $0
80107730:	6a 00                	push   $0x0
  pushl $40
80107732:	6a 28                	push   $0x28
  jmp alltraps
80107734:	e9 1f f8 ff ff       	jmp    80106f58 <alltraps>

80107739 <vector41>:
.globl vector41
vector41:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $41
8010773b:	6a 29                	push   $0x29
  jmp alltraps
8010773d:	e9 16 f8 ff ff       	jmp    80106f58 <alltraps>

80107742 <vector42>:
.globl vector42
vector42:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $42
80107744:	6a 2a                	push   $0x2a
  jmp alltraps
80107746:	e9 0d f8 ff ff       	jmp    80106f58 <alltraps>

8010774b <vector43>:
.globl vector43
vector43:
  pushl $0
8010774b:	6a 00                	push   $0x0
  pushl $43
8010774d:	6a 2b                	push   $0x2b
  jmp alltraps
8010774f:	e9 04 f8 ff ff       	jmp    80106f58 <alltraps>

80107754 <vector44>:
.globl vector44
vector44:
  pushl $0
80107754:	6a 00                	push   $0x0
  pushl $44
80107756:	6a 2c                	push   $0x2c
  jmp alltraps
80107758:	e9 fb f7 ff ff       	jmp    80106f58 <alltraps>

8010775d <vector45>:
.globl vector45
vector45:
  pushl $0
8010775d:	6a 00                	push   $0x0
  pushl $45
8010775f:	6a 2d                	push   $0x2d
  jmp alltraps
80107761:	e9 f2 f7 ff ff       	jmp    80106f58 <alltraps>

80107766 <vector46>:
.globl vector46
vector46:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $46
80107768:	6a 2e                	push   $0x2e
  jmp alltraps
8010776a:	e9 e9 f7 ff ff       	jmp    80106f58 <alltraps>

8010776f <vector47>:
.globl vector47
vector47:
  pushl $0
8010776f:	6a 00                	push   $0x0
  pushl $47
80107771:	6a 2f                	push   $0x2f
  jmp alltraps
80107773:	e9 e0 f7 ff ff       	jmp    80106f58 <alltraps>

80107778 <vector48>:
.globl vector48
vector48:
  pushl $0
80107778:	6a 00                	push   $0x0
  pushl $48
8010777a:	6a 30                	push   $0x30
  jmp alltraps
8010777c:	e9 d7 f7 ff ff       	jmp    80106f58 <alltraps>

80107781 <vector49>:
.globl vector49
vector49:
  pushl $0
80107781:	6a 00                	push   $0x0
  pushl $49
80107783:	6a 31                	push   $0x31
  jmp alltraps
80107785:	e9 ce f7 ff ff       	jmp    80106f58 <alltraps>

8010778a <vector50>:
.globl vector50
vector50:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $50
8010778c:	6a 32                	push   $0x32
  jmp alltraps
8010778e:	e9 c5 f7 ff ff       	jmp    80106f58 <alltraps>

80107793 <vector51>:
.globl vector51
vector51:
  pushl $0
80107793:	6a 00                	push   $0x0
  pushl $51
80107795:	6a 33                	push   $0x33
  jmp alltraps
80107797:	e9 bc f7 ff ff       	jmp    80106f58 <alltraps>

8010779c <vector52>:
.globl vector52
vector52:
  pushl $0
8010779c:	6a 00                	push   $0x0
  pushl $52
8010779e:	6a 34                	push   $0x34
  jmp alltraps
801077a0:	e9 b3 f7 ff ff       	jmp    80106f58 <alltraps>

801077a5 <vector53>:
.globl vector53
vector53:
  pushl $0
801077a5:	6a 00                	push   $0x0
  pushl $53
801077a7:	6a 35                	push   $0x35
  jmp alltraps
801077a9:	e9 aa f7 ff ff       	jmp    80106f58 <alltraps>

801077ae <vector54>:
.globl vector54
vector54:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $54
801077b0:	6a 36                	push   $0x36
  jmp alltraps
801077b2:	e9 a1 f7 ff ff       	jmp    80106f58 <alltraps>

801077b7 <vector55>:
.globl vector55
vector55:
  pushl $0
801077b7:	6a 00                	push   $0x0
  pushl $55
801077b9:	6a 37                	push   $0x37
  jmp alltraps
801077bb:	e9 98 f7 ff ff       	jmp    80106f58 <alltraps>

801077c0 <vector56>:
.globl vector56
vector56:
  pushl $0
801077c0:	6a 00                	push   $0x0
  pushl $56
801077c2:	6a 38                	push   $0x38
  jmp alltraps
801077c4:	e9 8f f7 ff ff       	jmp    80106f58 <alltraps>

801077c9 <vector57>:
.globl vector57
vector57:
  pushl $0
801077c9:	6a 00                	push   $0x0
  pushl $57
801077cb:	6a 39                	push   $0x39
  jmp alltraps
801077cd:	e9 86 f7 ff ff       	jmp    80106f58 <alltraps>

801077d2 <vector58>:
.globl vector58
vector58:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $58
801077d4:	6a 3a                	push   $0x3a
  jmp alltraps
801077d6:	e9 7d f7 ff ff       	jmp    80106f58 <alltraps>

801077db <vector59>:
.globl vector59
vector59:
  pushl $0
801077db:	6a 00                	push   $0x0
  pushl $59
801077dd:	6a 3b                	push   $0x3b
  jmp alltraps
801077df:	e9 74 f7 ff ff       	jmp    80106f58 <alltraps>

801077e4 <vector60>:
.globl vector60
vector60:
  pushl $0
801077e4:	6a 00                	push   $0x0
  pushl $60
801077e6:	6a 3c                	push   $0x3c
  jmp alltraps
801077e8:	e9 6b f7 ff ff       	jmp    80106f58 <alltraps>

801077ed <vector61>:
.globl vector61
vector61:
  pushl $0
801077ed:	6a 00                	push   $0x0
  pushl $61
801077ef:	6a 3d                	push   $0x3d
  jmp alltraps
801077f1:	e9 62 f7 ff ff       	jmp    80106f58 <alltraps>

801077f6 <vector62>:
.globl vector62
vector62:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $62
801077f8:	6a 3e                	push   $0x3e
  jmp alltraps
801077fa:	e9 59 f7 ff ff       	jmp    80106f58 <alltraps>

801077ff <vector63>:
.globl vector63
vector63:
  pushl $0
801077ff:	6a 00                	push   $0x0
  pushl $63
80107801:	6a 3f                	push   $0x3f
  jmp alltraps
80107803:	e9 50 f7 ff ff       	jmp    80106f58 <alltraps>

80107808 <vector64>:
.globl vector64
vector64:
  pushl $0
80107808:	6a 00                	push   $0x0
  pushl $64
8010780a:	6a 40                	push   $0x40
  jmp alltraps
8010780c:	e9 47 f7 ff ff       	jmp    80106f58 <alltraps>

80107811 <vector65>:
.globl vector65
vector65:
  pushl $0
80107811:	6a 00                	push   $0x0
  pushl $65
80107813:	6a 41                	push   $0x41
  jmp alltraps
80107815:	e9 3e f7 ff ff       	jmp    80106f58 <alltraps>

8010781a <vector66>:
.globl vector66
vector66:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $66
8010781c:	6a 42                	push   $0x42
  jmp alltraps
8010781e:	e9 35 f7 ff ff       	jmp    80106f58 <alltraps>

80107823 <vector67>:
.globl vector67
vector67:
  pushl $0
80107823:	6a 00                	push   $0x0
  pushl $67
80107825:	6a 43                	push   $0x43
  jmp alltraps
80107827:	e9 2c f7 ff ff       	jmp    80106f58 <alltraps>

8010782c <vector68>:
.globl vector68
vector68:
  pushl $0
8010782c:	6a 00                	push   $0x0
  pushl $68
8010782e:	6a 44                	push   $0x44
  jmp alltraps
80107830:	e9 23 f7 ff ff       	jmp    80106f58 <alltraps>

80107835 <vector69>:
.globl vector69
vector69:
  pushl $0
80107835:	6a 00                	push   $0x0
  pushl $69
80107837:	6a 45                	push   $0x45
  jmp alltraps
80107839:	e9 1a f7 ff ff       	jmp    80106f58 <alltraps>

8010783e <vector70>:
.globl vector70
vector70:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $70
80107840:	6a 46                	push   $0x46
  jmp alltraps
80107842:	e9 11 f7 ff ff       	jmp    80106f58 <alltraps>

80107847 <vector71>:
.globl vector71
vector71:
  pushl $0
80107847:	6a 00                	push   $0x0
  pushl $71
80107849:	6a 47                	push   $0x47
  jmp alltraps
8010784b:	e9 08 f7 ff ff       	jmp    80106f58 <alltraps>

80107850 <vector72>:
.globl vector72
vector72:
  pushl $0
80107850:	6a 00                	push   $0x0
  pushl $72
80107852:	6a 48                	push   $0x48
  jmp alltraps
80107854:	e9 ff f6 ff ff       	jmp    80106f58 <alltraps>

80107859 <vector73>:
.globl vector73
vector73:
  pushl $0
80107859:	6a 00                	push   $0x0
  pushl $73
8010785b:	6a 49                	push   $0x49
  jmp alltraps
8010785d:	e9 f6 f6 ff ff       	jmp    80106f58 <alltraps>

80107862 <vector74>:
.globl vector74
vector74:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $74
80107864:	6a 4a                	push   $0x4a
  jmp alltraps
80107866:	e9 ed f6 ff ff       	jmp    80106f58 <alltraps>

8010786b <vector75>:
.globl vector75
vector75:
  pushl $0
8010786b:	6a 00                	push   $0x0
  pushl $75
8010786d:	6a 4b                	push   $0x4b
  jmp alltraps
8010786f:	e9 e4 f6 ff ff       	jmp    80106f58 <alltraps>

80107874 <vector76>:
.globl vector76
vector76:
  pushl $0
80107874:	6a 00                	push   $0x0
  pushl $76
80107876:	6a 4c                	push   $0x4c
  jmp alltraps
80107878:	e9 db f6 ff ff       	jmp    80106f58 <alltraps>

8010787d <vector77>:
.globl vector77
vector77:
  pushl $0
8010787d:	6a 00                	push   $0x0
  pushl $77
8010787f:	6a 4d                	push   $0x4d
  jmp alltraps
80107881:	e9 d2 f6 ff ff       	jmp    80106f58 <alltraps>

80107886 <vector78>:
.globl vector78
vector78:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $78
80107888:	6a 4e                	push   $0x4e
  jmp alltraps
8010788a:	e9 c9 f6 ff ff       	jmp    80106f58 <alltraps>

8010788f <vector79>:
.globl vector79
vector79:
  pushl $0
8010788f:	6a 00                	push   $0x0
  pushl $79
80107891:	6a 4f                	push   $0x4f
  jmp alltraps
80107893:	e9 c0 f6 ff ff       	jmp    80106f58 <alltraps>

80107898 <vector80>:
.globl vector80
vector80:
  pushl $0
80107898:	6a 00                	push   $0x0
  pushl $80
8010789a:	6a 50                	push   $0x50
  jmp alltraps
8010789c:	e9 b7 f6 ff ff       	jmp    80106f58 <alltraps>

801078a1 <vector81>:
.globl vector81
vector81:
  pushl $0
801078a1:	6a 00                	push   $0x0
  pushl $81
801078a3:	6a 51                	push   $0x51
  jmp alltraps
801078a5:	e9 ae f6 ff ff       	jmp    80106f58 <alltraps>

801078aa <vector82>:
.globl vector82
vector82:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $82
801078ac:	6a 52                	push   $0x52
  jmp alltraps
801078ae:	e9 a5 f6 ff ff       	jmp    80106f58 <alltraps>

801078b3 <vector83>:
.globl vector83
vector83:
  pushl $0
801078b3:	6a 00                	push   $0x0
  pushl $83
801078b5:	6a 53                	push   $0x53
  jmp alltraps
801078b7:	e9 9c f6 ff ff       	jmp    80106f58 <alltraps>

801078bc <vector84>:
.globl vector84
vector84:
  pushl $0
801078bc:	6a 00                	push   $0x0
  pushl $84
801078be:	6a 54                	push   $0x54
  jmp alltraps
801078c0:	e9 93 f6 ff ff       	jmp    80106f58 <alltraps>

801078c5 <vector85>:
.globl vector85
vector85:
  pushl $0
801078c5:	6a 00                	push   $0x0
  pushl $85
801078c7:	6a 55                	push   $0x55
  jmp alltraps
801078c9:	e9 8a f6 ff ff       	jmp    80106f58 <alltraps>

801078ce <vector86>:
.globl vector86
vector86:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $86
801078d0:	6a 56                	push   $0x56
  jmp alltraps
801078d2:	e9 81 f6 ff ff       	jmp    80106f58 <alltraps>

801078d7 <vector87>:
.globl vector87
vector87:
  pushl $0
801078d7:	6a 00                	push   $0x0
  pushl $87
801078d9:	6a 57                	push   $0x57
  jmp alltraps
801078db:	e9 78 f6 ff ff       	jmp    80106f58 <alltraps>

801078e0 <vector88>:
.globl vector88
vector88:
  pushl $0
801078e0:	6a 00                	push   $0x0
  pushl $88
801078e2:	6a 58                	push   $0x58
  jmp alltraps
801078e4:	e9 6f f6 ff ff       	jmp    80106f58 <alltraps>

801078e9 <vector89>:
.globl vector89
vector89:
  pushl $0
801078e9:	6a 00                	push   $0x0
  pushl $89
801078eb:	6a 59                	push   $0x59
  jmp alltraps
801078ed:	e9 66 f6 ff ff       	jmp    80106f58 <alltraps>

801078f2 <vector90>:
.globl vector90
vector90:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $90
801078f4:	6a 5a                	push   $0x5a
  jmp alltraps
801078f6:	e9 5d f6 ff ff       	jmp    80106f58 <alltraps>

801078fb <vector91>:
.globl vector91
vector91:
  pushl $0
801078fb:	6a 00                	push   $0x0
  pushl $91
801078fd:	6a 5b                	push   $0x5b
  jmp alltraps
801078ff:	e9 54 f6 ff ff       	jmp    80106f58 <alltraps>

80107904 <vector92>:
.globl vector92
vector92:
  pushl $0
80107904:	6a 00                	push   $0x0
  pushl $92
80107906:	6a 5c                	push   $0x5c
  jmp alltraps
80107908:	e9 4b f6 ff ff       	jmp    80106f58 <alltraps>

8010790d <vector93>:
.globl vector93
vector93:
  pushl $0
8010790d:	6a 00                	push   $0x0
  pushl $93
8010790f:	6a 5d                	push   $0x5d
  jmp alltraps
80107911:	e9 42 f6 ff ff       	jmp    80106f58 <alltraps>

80107916 <vector94>:
.globl vector94
vector94:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $94
80107918:	6a 5e                	push   $0x5e
  jmp alltraps
8010791a:	e9 39 f6 ff ff       	jmp    80106f58 <alltraps>

8010791f <vector95>:
.globl vector95
vector95:
  pushl $0
8010791f:	6a 00                	push   $0x0
  pushl $95
80107921:	6a 5f                	push   $0x5f
  jmp alltraps
80107923:	e9 30 f6 ff ff       	jmp    80106f58 <alltraps>

80107928 <vector96>:
.globl vector96
vector96:
  pushl $0
80107928:	6a 00                	push   $0x0
  pushl $96
8010792a:	6a 60                	push   $0x60
  jmp alltraps
8010792c:	e9 27 f6 ff ff       	jmp    80106f58 <alltraps>

80107931 <vector97>:
.globl vector97
vector97:
  pushl $0
80107931:	6a 00                	push   $0x0
  pushl $97
80107933:	6a 61                	push   $0x61
  jmp alltraps
80107935:	e9 1e f6 ff ff       	jmp    80106f58 <alltraps>

8010793a <vector98>:
.globl vector98
vector98:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $98
8010793c:	6a 62                	push   $0x62
  jmp alltraps
8010793e:	e9 15 f6 ff ff       	jmp    80106f58 <alltraps>

80107943 <vector99>:
.globl vector99
vector99:
  pushl $0
80107943:	6a 00                	push   $0x0
  pushl $99
80107945:	6a 63                	push   $0x63
  jmp alltraps
80107947:	e9 0c f6 ff ff       	jmp    80106f58 <alltraps>

8010794c <vector100>:
.globl vector100
vector100:
  pushl $0
8010794c:	6a 00                	push   $0x0
  pushl $100
8010794e:	6a 64                	push   $0x64
  jmp alltraps
80107950:	e9 03 f6 ff ff       	jmp    80106f58 <alltraps>

80107955 <vector101>:
.globl vector101
vector101:
  pushl $0
80107955:	6a 00                	push   $0x0
  pushl $101
80107957:	6a 65                	push   $0x65
  jmp alltraps
80107959:	e9 fa f5 ff ff       	jmp    80106f58 <alltraps>

8010795e <vector102>:
.globl vector102
vector102:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $102
80107960:	6a 66                	push   $0x66
  jmp alltraps
80107962:	e9 f1 f5 ff ff       	jmp    80106f58 <alltraps>

80107967 <vector103>:
.globl vector103
vector103:
  pushl $0
80107967:	6a 00                	push   $0x0
  pushl $103
80107969:	6a 67                	push   $0x67
  jmp alltraps
8010796b:	e9 e8 f5 ff ff       	jmp    80106f58 <alltraps>

80107970 <vector104>:
.globl vector104
vector104:
  pushl $0
80107970:	6a 00                	push   $0x0
  pushl $104
80107972:	6a 68                	push   $0x68
  jmp alltraps
80107974:	e9 df f5 ff ff       	jmp    80106f58 <alltraps>

80107979 <vector105>:
.globl vector105
vector105:
  pushl $0
80107979:	6a 00                	push   $0x0
  pushl $105
8010797b:	6a 69                	push   $0x69
  jmp alltraps
8010797d:	e9 d6 f5 ff ff       	jmp    80106f58 <alltraps>

80107982 <vector106>:
.globl vector106
vector106:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $106
80107984:	6a 6a                	push   $0x6a
  jmp alltraps
80107986:	e9 cd f5 ff ff       	jmp    80106f58 <alltraps>

8010798b <vector107>:
.globl vector107
vector107:
  pushl $0
8010798b:	6a 00                	push   $0x0
  pushl $107
8010798d:	6a 6b                	push   $0x6b
  jmp alltraps
8010798f:	e9 c4 f5 ff ff       	jmp    80106f58 <alltraps>

80107994 <vector108>:
.globl vector108
vector108:
  pushl $0
80107994:	6a 00                	push   $0x0
  pushl $108
80107996:	6a 6c                	push   $0x6c
  jmp alltraps
80107998:	e9 bb f5 ff ff       	jmp    80106f58 <alltraps>

8010799d <vector109>:
.globl vector109
vector109:
  pushl $0
8010799d:	6a 00                	push   $0x0
  pushl $109
8010799f:	6a 6d                	push   $0x6d
  jmp alltraps
801079a1:	e9 b2 f5 ff ff       	jmp    80106f58 <alltraps>

801079a6 <vector110>:
.globl vector110
vector110:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $110
801079a8:	6a 6e                	push   $0x6e
  jmp alltraps
801079aa:	e9 a9 f5 ff ff       	jmp    80106f58 <alltraps>

801079af <vector111>:
.globl vector111
vector111:
  pushl $0
801079af:	6a 00                	push   $0x0
  pushl $111
801079b1:	6a 6f                	push   $0x6f
  jmp alltraps
801079b3:	e9 a0 f5 ff ff       	jmp    80106f58 <alltraps>

801079b8 <vector112>:
.globl vector112
vector112:
  pushl $0
801079b8:	6a 00                	push   $0x0
  pushl $112
801079ba:	6a 70                	push   $0x70
  jmp alltraps
801079bc:	e9 97 f5 ff ff       	jmp    80106f58 <alltraps>

801079c1 <vector113>:
.globl vector113
vector113:
  pushl $0
801079c1:	6a 00                	push   $0x0
  pushl $113
801079c3:	6a 71                	push   $0x71
  jmp alltraps
801079c5:	e9 8e f5 ff ff       	jmp    80106f58 <alltraps>

801079ca <vector114>:
.globl vector114
vector114:
  pushl $0
801079ca:	6a 00                	push   $0x0
  pushl $114
801079cc:	6a 72                	push   $0x72
  jmp alltraps
801079ce:	e9 85 f5 ff ff       	jmp    80106f58 <alltraps>

801079d3 <vector115>:
.globl vector115
vector115:
  pushl $0
801079d3:	6a 00                	push   $0x0
  pushl $115
801079d5:	6a 73                	push   $0x73
  jmp alltraps
801079d7:	e9 7c f5 ff ff       	jmp    80106f58 <alltraps>

801079dc <vector116>:
.globl vector116
vector116:
  pushl $0
801079dc:	6a 00                	push   $0x0
  pushl $116
801079de:	6a 74                	push   $0x74
  jmp alltraps
801079e0:	e9 73 f5 ff ff       	jmp    80106f58 <alltraps>

801079e5 <vector117>:
.globl vector117
vector117:
  pushl $0
801079e5:	6a 00                	push   $0x0
  pushl $117
801079e7:	6a 75                	push   $0x75
  jmp alltraps
801079e9:	e9 6a f5 ff ff       	jmp    80106f58 <alltraps>

801079ee <vector118>:
.globl vector118
vector118:
  pushl $0
801079ee:	6a 00                	push   $0x0
  pushl $118
801079f0:	6a 76                	push   $0x76
  jmp alltraps
801079f2:	e9 61 f5 ff ff       	jmp    80106f58 <alltraps>

801079f7 <vector119>:
.globl vector119
vector119:
  pushl $0
801079f7:	6a 00                	push   $0x0
  pushl $119
801079f9:	6a 77                	push   $0x77
  jmp alltraps
801079fb:	e9 58 f5 ff ff       	jmp    80106f58 <alltraps>

80107a00 <vector120>:
.globl vector120
vector120:
  pushl $0
80107a00:	6a 00                	push   $0x0
  pushl $120
80107a02:	6a 78                	push   $0x78
  jmp alltraps
80107a04:	e9 4f f5 ff ff       	jmp    80106f58 <alltraps>

80107a09 <vector121>:
.globl vector121
vector121:
  pushl $0
80107a09:	6a 00                	push   $0x0
  pushl $121
80107a0b:	6a 79                	push   $0x79
  jmp alltraps
80107a0d:	e9 46 f5 ff ff       	jmp    80106f58 <alltraps>

80107a12 <vector122>:
.globl vector122
vector122:
  pushl $0
80107a12:	6a 00                	push   $0x0
  pushl $122
80107a14:	6a 7a                	push   $0x7a
  jmp alltraps
80107a16:	e9 3d f5 ff ff       	jmp    80106f58 <alltraps>

80107a1b <vector123>:
.globl vector123
vector123:
  pushl $0
80107a1b:	6a 00                	push   $0x0
  pushl $123
80107a1d:	6a 7b                	push   $0x7b
  jmp alltraps
80107a1f:	e9 34 f5 ff ff       	jmp    80106f58 <alltraps>

80107a24 <vector124>:
.globl vector124
vector124:
  pushl $0
80107a24:	6a 00                	push   $0x0
  pushl $124
80107a26:	6a 7c                	push   $0x7c
  jmp alltraps
80107a28:	e9 2b f5 ff ff       	jmp    80106f58 <alltraps>

80107a2d <vector125>:
.globl vector125
vector125:
  pushl $0
80107a2d:	6a 00                	push   $0x0
  pushl $125
80107a2f:	6a 7d                	push   $0x7d
  jmp alltraps
80107a31:	e9 22 f5 ff ff       	jmp    80106f58 <alltraps>

80107a36 <vector126>:
.globl vector126
vector126:
  pushl $0
80107a36:	6a 00                	push   $0x0
  pushl $126
80107a38:	6a 7e                	push   $0x7e
  jmp alltraps
80107a3a:	e9 19 f5 ff ff       	jmp    80106f58 <alltraps>

80107a3f <vector127>:
.globl vector127
vector127:
  pushl $0
80107a3f:	6a 00                	push   $0x0
  pushl $127
80107a41:	6a 7f                	push   $0x7f
  jmp alltraps
80107a43:	e9 10 f5 ff ff       	jmp    80106f58 <alltraps>

80107a48 <vector128>:
.globl vector128
vector128:
  pushl $0
80107a48:	6a 00                	push   $0x0
  pushl $128
80107a4a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107a4f:	e9 04 f5 ff ff       	jmp    80106f58 <alltraps>

80107a54 <vector129>:
.globl vector129
vector129:
  pushl $0
80107a54:	6a 00                	push   $0x0
  pushl $129
80107a56:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107a5b:	e9 f8 f4 ff ff       	jmp    80106f58 <alltraps>

80107a60 <vector130>:
.globl vector130
vector130:
  pushl $0
80107a60:	6a 00                	push   $0x0
  pushl $130
80107a62:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107a67:	e9 ec f4 ff ff       	jmp    80106f58 <alltraps>

80107a6c <vector131>:
.globl vector131
vector131:
  pushl $0
80107a6c:	6a 00                	push   $0x0
  pushl $131
80107a6e:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107a73:	e9 e0 f4 ff ff       	jmp    80106f58 <alltraps>

80107a78 <vector132>:
.globl vector132
vector132:
  pushl $0
80107a78:	6a 00                	push   $0x0
  pushl $132
80107a7a:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107a7f:	e9 d4 f4 ff ff       	jmp    80106f58 <alltraps>

80107a84 <vector133>:
.globl vector133
vector133:
  pushl $0
80107a84:	6a 00                	push   $0x0
  pushl $133
80107a86:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107a8b:	e9 c8 f4 ff ff       	jmp    80106f58 <alltraps>

80107a90 <vector134>:
.globl vector134
vector134:
  pushl $0
80107a90:	6a 00                	push   $0x0
  pushl $134
80107a92:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107a97:	e9 bc f4 ff ff       	jmp    80106f58 <alltraps>

80107a9c <vector135>:
.globl vector135
vector135:
  pushl $0
80107a9c:	6a 00                	push   $0x0
  pushl $135
80107a9e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107aa3:	e9 b0 f4 ff ff       	jmp    80106f58 <alltraps>

80107aa8 <vector136>:
.globl vector136
vector136:
  pushl $0
80107aa8:	6a 00                	push   $0x0
  pushl $136
80107aaa:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107aaf:	e9 a4 f4 ff ff       	jmp    80106f58 <alltraps>

80107ab4 <vector137>:
.globl vector137
vector137:
  pushl $0
80107ab4:	6a 00                	push   $0x0
  pushl $137
80107ab6:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107abb:	e9 98 f4 ff ff       	jmp    80106f58 <alltraps>

80107ac0 <vector138>:
.globl vector138
vector138:
  pushl $0
80107ac0:	6a 00                	push   $0x0
  pushl $138
80107ac2:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107ac7:	e9 8c f4 ff ff       	jmp    80106f58 <alltraps>

80107acc <vector139>:
.globl vector139
vector139:
  pushl $0
80107acc:	6a 00                	push   $0x0
  pushl $139
80107ace:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107ad3:	e9 80 f4 ff ff       	jmp    80106f58 <alltraps>

80107ad8 <vector140>:
.globl vector140
vector140:
  pushl $0
80107ad8:	6a 00                	push   $0x0
  pushl $140
80107ada:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107adf:	e9 74 f4 ff ff       	jmp    80106f58 <alltraps>

80107ae4 <vector141>:
.globl vector141
vector141:
  pushl $0
80107ae4:	6a 00                	push   $0x0
  pushl $141
80107ae6:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107aeb:	e9 68 f4 ff ff       	jmp    80106f58 <alltraps>

80107af0 <vector142>:
.globl vector142
vector142:
  pushl $0
80107af0:	6a 00                	push   $0x0
  pushl $142
80107af2:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107af7:	e9 5c f4 ff ff       	jmp    80106f58 <alltraps>

80107afc <vector143>:
.globl vector143
vector143:
  pushl $0
80107afc:	6a 00                	push   $0x0
  pushl $143
80107afe:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107b03:	e9 50 f4 ff ff       	jmp    80106f58 <alltraps>

80107b08 <vector144>:
.globl vector144
vector144:
  pushl $0
80107b08:	6a 00                	push   $0x0
  pushl $144
80107b0a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107b0f:	e9 44 f4 ff ff       	jmp    80106f58 <alltraps>

80107b14 <vector145>:
.globl vector145
vector145:
  pushl $0
80107b14:	6a 00                	push   $0x0
  pushl $145
80107b16:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107b1b:	e9 38 f4 ff ff       	jmp    80106f58 <alltraps>

80107b20 <vector146>:
.globl vector146
vector146:
  pushl $0
80107b20:	6a 00                	push   $0x0
  pushl $146
80107b22:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107b27:	e9 2c f4 ff ff       	jmp    80106f58 <alltraps>

80107b2c <vector147>:
.globl vector147
vector147:
  pushl $0
80107b2c:	6a 00                	push   $0x0
  pushl $147
80107b2e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107b33:	e9 20 f4 ff ff       	jmp    80106f58 <alltraps>

80107b38 <vector148>:
.globl vector148
vector148:
  pushl $0
80107b38:	6a 00                	push   $0x0
  pushl $148
80107b3a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107b3f:	e9 14 f4 ff ff       	jmp    80106f58 <alltraps>

80107b44 <vector149>:
.globl vector149
vector149:
  pushl $0
80107b44:	6a 00                	push   $0x0
  pushl $149
80107b46:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107b4b:	e9 08 f4 ff ff       	jmp    80106f58 <alltraps>

80107b50 <vector150>:
.globl vector150
vector150:
  pushl $0
80107b50:	6a 00                	push   $0x0
  pushl $150
80107b52:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107b57:	e9 fc f3 ff ff       	jmp    80106f58 <alltraps>

80107b5c <vector151>:
.globl vector151
vector151:
  pushl $0
80107b5c:	6a 00                	push   $0x0
  pushl $151
80107b5e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107b63:	e9 f0 f3 ff ff       	jmp    80106f58 <alltraps>

80107b68 <vector152>:
.globl vector152
vector152:
  pushl $0
80107b68:	6a 00                	push   $0x0
  pushl $152
80107b6a:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107b6f:	e9 e4 f3 ff ff       	jmp    80106f58 <alltraps>

80107b74 <vector153>:
.globl vector153
vector153:
  pushl $0
80107b74:	6a 00                	push   $0x0
  pushl $153
80107b76:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107b7b:	e9 d8 f3 ff ff       	jmp    80106f58 <alltraps>

80107b80 <vector154>:
.globl vector154
vector154:
  pushl $0
80107b80:	6a 00                	push   $0x0
  pushl $154
80107b82:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107b87:	e9 cc f3 ff ff       	jmp    80106f58 <alltraps>

80107b8c <vector155>:
.globl vector155
vector155:
  pushl $0
80107b8c:	6a 00                	push   $0x0
  pushl $155
80107b8e:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107b93:	e9 c0 f3 ff ff       	jmp    80106f58 <alltraps>

80107b98 <vector156>:
.globl vector156
vector156:
  pushl $0
80107b98:	6a 00                	push   $0x0
  pushl $156
80107b9a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107b9f:	e9 b4 f3 ff ff       	jmp    80106f58 <alltraps>

80107ba4 <vector157>:
.globl vector157
vector157:
  pushl $0
80107ba4:	6a 00                	push   $0x0
  pushl $157
80107ba6:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107bab:	e9 a8 f3 ff ff       	jmp    80106f58 <alltraps>

80107bb0 <vector158>:
.globl vector158
vector158:
  pushl $0
80107bb0:	6a 00                	push   $0x0
  pushl $158
80107bb2:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107bb7:	e9 9c f3 ff ff       	jmp    80106f58 <alltraps>

80107bbc <vector159>:
.globl vector159
vector159:
  pushl $0
80107bbc:	6a 00                	push   $0x0
  pushl $159
80107bbe:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107bc3:	e9 90 f3 ff ff       	jmp    80106f58 <alltraps>

80107bc8 <vector160>:
.globl vector160
vector160:
  pushl $0
80107bc8:	6a 00                	push   $0x0
  pushl $160
80107bca:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107bcf:	e9 84 f3 ff ff       	jmp    80106f58 <alltraps>

80107bd4 <vector161>:
.globl vector161
vector161:
  pushl $0
80107bd4:	6a 00                	push   $0x0
  pushl $161
80107bd6:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107bdb:	e9 78 f3 ff ff       	jmp    80106f58 <alltraps>

80107be0 <vector162>:
.globl vector162
vector162:
  pushl $0
80107be0:	6a 00                	push   $0x0
  pushl $162
80107be2:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107be7:	e9 6c f3 ff ff       	jmp    80106f58 <alltraps>

80107bec <vector163>:
.globl vector163
vector163:
  pushl $0
80107bec:	6a 00                	push   $0x0
  pushl $163
80107bee:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107bf3:	e9 60 f3 ff ff       	jmp    80106f58 <alltraps>

80107bf8 <vector164>:
.globl vector164
vector164:
  pushl $0
80107bf8:	6a 00                	push   $0x0
  pushl $164
80107bfa:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107bff:	e9 54 f3 ff ff       	jmp    80106f58 <alltraps>

80107c04 <vector165>:
.globl vector165
vector165:
  pushl $0
80107c04:	6a 00                	push   $0x0
  pushl $165
80107c06:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107c0b:	e9 48 f3 ff ff       	jmp    80106f58 <alltraps>

80107c10 <vector166>:
.globl vector166
vector166:
  pushl $0
80107c10:	6a 00                	push   $0x0
  pushl $166
80107c12:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107c17:	e9 3c f3 ff ff       	jmp    80106f58 <alltraps>

80107c1c <vector167>:
.globl vector167
vector167:
  pushl $0
80107c1c:	6a 00                	push   $0x0
  pushl $167
80107c1e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107c23:	e9 30 f3 ff ff       	jmp    80106f58 <alltraps>

80107c28 <vector168>:
.globl vector168
vector168:
  pushl $0
80107c28:	6a 00                	push   $0x0
  pushl $168
80107c2a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107c2f:	e9 24 f3 ff ff       	jmp    80106f58 <alltraps>

80107c34 <vector169>:
.globl vector169
vector169:
  pushl $0
80107c34:	6a 00                	push   $0x0
  pushl $169
80107c36:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107c3b:	e9 18 f3 ff ff       	jmp    80106f58 <alltraps>

80107c40 <vector170>:
.globl vector170
vector170:
  pushl $0
80107c40:	6a 00                	push   $0x0
  pushl $170
80107c42:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107c47:	e9 0c f3 ff ff       	jmp    80106f58 <alltraps>

80107c4c <vector171>:
.globl vector171
vector171:
  pushl $0
80107c4c:	6a 00                	push   $0x0
  pushl $171
80107c4e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107c53:	e9 00 f3 ff ff       	jmp    80106f58 <alltraps>

80107c58 <vector172>:
.globl vector172
vector172:
  pushl $0
80107c58:	6a 00                	push   $0x0
  pushl $172
80107c5a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107c5f:	e9 f4 f2 ff ff       	jmp    80106f58 <alltraps>

80107c64 <vector173>:
.globl vector173
vector173:
  pushl $0
80107c64:	6a 00                	push   $0x0
  pushl $173
80107c66:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107c6b:	e9 e8 f2 ff ff       	jmp    80106f58 <alltraps>

80107c70 <vector174>:
.globl vector174
vector174:
  pushl $0
80107c70:	6a 00                	push   $0x0
  pushl $174
80107c72:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107c77:	e9 dc f2 ff ff       	jmp    80106f58 <alltraps>

80107c7c <vector175>:
.globl vector175
vector175:
  pushl $0
80107c7c:	6a 00                	push   $0x0
  pushl $175
80107c7e:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107c83:	e9 d0 f2 ff ff       	jmp    80106f58 <alltraps>

80107c88 <vector176>:
.globl vector176
vector176:
  pushl $0
80107c88:	6a 00                	push   $0x0
  pushl $176
80107c8a:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107c8f:	e9 c4 f2 ff ff       	jmp    80106f58 <alltraps>

80107c94 <vector177>:
.globl vector177
vector177:
  pushl $0
80107c94:	6a 00                	push   $0x0
  pushl $177
80107c96:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107c9b:	e9 b8 f2 ff ff       	jmp    80106f58 <alltraps>

80107ca0 <vector178>:
.globl vector178
vector178:
  pushl $0
80107ca0:	6a 00                	push   $0x0
  pushl $178
80107ca2:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107ca7:	e9 ac f2 ff ff       	jmp    80106f58 <alltraps>

80107cac <vector179>:
.globl vector179
vector179:
  pushl $0
80107cac:	6a 00                	push   $0x0
  pushl $179
80107cae:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107cb3:	e9 a0 f2 ff ff       	jmp    80106f58 <alltraps>

80107cb8 <vector180>:
.globl vector180
vector180:
  pushl $0
80107cb8:	6a 00                	push   $0x0
  pushl $180
80107cba:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107cbf:	e9 94 f2 ff ff       	jmp    80106f58 <alltraps>

80107cc4 <vector181>:
.globl vector181
vector181:
  pushl $0
80107cc4:	6a 00                	push   $0x0
  pushl $181
80107cc6:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107ccb:	e9 88 f2 ff ff       	jmp    80106f58 <alltraps>

80107cd0 <vector182>:
.globl vector182
vector182:
  pushl $0
80107cd0:	6a 00                	push   $0x0
  pushl $182
80107cd2:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107cd7:	e9 7c f2 ff ff       	jmp    80106f58 <alltraps>

80107cdc <vector183>:
.globl vector183
vector183:
  pushl $0
80107cdc:	6a 00                	push   $0x0
  pushl $183
80107cde:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107ce3:	e9 70 f2 ff ff       	jmp    80106f58 <alltraps>

80107ce8 <vector184>:
.globl vector184
vector184:
  pushl $0
80107ce8:	6a 00                	push   $0x0
  pushl $184
80107cea:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107cef:	e9 64 f2 ff ff       	jmp    80106f58 <alltraps>

80107cf4 <vector185>:
.globl vector185
vector185:
  pushl $0
80107cf4:	6a 00                	push   $0x0
  pushl $185
80107cf6:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107cfb:	e9 58 f2 ff ff       	jmp    80106f58 <alltraps>

80107d00 <vector186>:
.globl vector186
vector186:
  pushl $0
80107d00:	6a 00                	push   $0x0
  pushl $186
80107d02:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107d07:	e9 4c f2 ff ff       	jmp    80106f58 <alltraps>

80107d0c <vector187>:
.globl vector187
vector187:
  pushl $0
80107d0c:	6a 00                	push   $0x0
  pushl $187
80107d0e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107d13:	e9 40 f2 ff ff       	jmp    80106f58 <alltraps>

80107d18 <vector188>:
.globl vector188
vector188:
  pushl $0
80107d18:	6a 00                	push   $0x0
  pushl $188
80107d1a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107d1f:	e9 34 f2 ff ff       	jmp    80106f58 <alltraps>

80107d24 <vector189>:
.globl vector189
vector189:
  pushl $0
80107d24:	6a 00                	push   $0x0
  pushl $189
80107d26:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107d2b:	e9 28 f2 ff ff       	jmp    80106f58 <alltraps>

80107d30 <vector190>:
.globl vector190
vector190:
  pushl $0
80107d30:	6a 00                	push   $0x0
  pushl $190
80107d32:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107d37:	e9 1c f2 ff ff       	jmp    80106f58 <alltraps>

80107d3c <vector191>:
.globl vector191
vector191:
  pushl $0
80107d3c:	6a 00                	push   $0x0
  pushl $191
80107d3e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107d43:	e9 10 f2 ff ff       	jmp    80106f58 <alltraps>

80107d48 <vector192>:
.globl vector192
vector192:
  pushl $0
80107d48:	6a 00                	push   $0x0
  pushl $192
80107d4a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107d4f:	e9 04 f2 ff ff       	jmp    80106f58 <alltraps>

80107d54 <vector193>:
.globl vector193
vector193:
  pushl $0
80107d54:	6a 00                	push   $0x0
  pushl $193
80107d56:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107d5b:	e9 f8 f1 ff ff       	jmp    80106f58 <alltraps>

80107d60 <vector194>:
.globl vector194
vector194:
  pushl $0
80107d60:	6a 00                	push   $0x0
  pushl $194
80107d62:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107d67:	e9 ec f1 ff ff       	jmp    80106f58 <alltraps>

80107d6c <vector195>:
.globl vector195
vector195:
  pushl $0
80107d6c:	6a 00                	push   $0x0
  pushl $195
80107d6e:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107d73:	e9 e0 f1 ff ff       	jmp    80106f58 <alltraps>

80107d78 <vector196>:
.globl vector196
vector196:
  pushl $0
80107d78:	6a 00                	push   $0x0
  pushl $196
80107d7a:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107d7f:	e9 d4 f1 ff ff       	jmp    80106f58 <alltraps>

80107d84 <vector197>:
.globl vector197
vector197:
  pushl $0
80107d84:	6a 00                	push   $0x0
  pushl $197
80107d86:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107d8b:	e9 c8 f1 ff ff       	jmp    80106f58 <alltraps>

80107d90 <vector198>:
.globl vector198
vector198:
  pushl $0
80107d90:	6a 00                	push   $0x0
  pushl $198
80107d92:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107d97:	e9 bc f1 ff ff       	jmp    80106f58 <alltraps>

80107d9c <vector199>:
.globl vector199
vector199:
  pushl $0
80107d9c:	6a 00                	push   $0x0
  pushl $199
80107d9e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107da3:	e9 b0 f1 ff ff       	jmp    80106f58 <alltraps>

80107da8 <vector200>:
.globl vector200
vector200:
  pushl $0
80107da8:	6a 00                	push   $0x0
  pushl $200
80107daa:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107daf:	e9 a4 f1 ff ff       	jmp    80106f58 <alltraps>

80107db4 <vector201>:
.globl vector201
vector201:
  pushl $0
80107db4:	6a 00                	push   $0x0
  pushl $201
80107db6:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107dbb:	e9 98 f1 ff ff       	jmp    80106f58 <alltraps>

80107dc0 <vector202>:
.globl vector202
vector202:
  pushl $0
80107dc0:	6a 00                	push   $0x0
  pushl $202
80107dc2:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107dc7:	e9 8c f1 ff ff       	jmp    80106f58 <alltraps>

80107dcc <vector203>:
.globl vector203
vector203:
  pushl $0
80107dcc:	6a 00                	push   $0x0
  pushl $203
80107dce:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107dd3:	e9 80 f1 ff ff       	jmp    80106f58 <alltraps>

80107dd8 <vector204>:
.globl vector204
vector204:
  pushl $0
80107dd8:	6a 00                	push   $0x0
  pushl $204
80107dda:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107ddf:	e9 74 f1 ff ff       	jmp    80106f58 <alltraps>

80107de4 <vector205>:
.globl vector205
vector205:
  pushl $0
80107de4:	6a 00                	push   $0x0
  pushl $205
80107de6:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107deb:	e9 68 f1 ff ff       	jmp    80106f58 <alltraps>

80107df0 <vector206>:
.globl vector206
vector206:
  pushl $0
80107df0:	6a 00                	push   $0x0
  pushl $206
80107df2:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107df7:	e9 5c f1 ff ff       	jmp    80106f58 <alltraps>

80107dfc <vector207>:
.globl vector207
vector207:
  pushl $0
80107dfc:	6a 00                	push   $0x0
  pushl $207
80107dfe:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107e03:	e9 50 f1 ff ff       	jmp    80106f58 <alltraps>

80107e08 <vector208>:
.globl vector208
vector208:
  pushl $0
80107e08:	6a 00                	push   $0x0
  pushl $208
80107e0a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107e0f:	e9 44 f1 ff ff       	jmp    80106f58 <alltraps>

80107e14 <vector209>:
.globl vector209
vector209:
  pushl $0
80107e14:	6a 00                	push   $0x0
  pushl $209
80107e16:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107e1b:	e9 38 f1 ff ff       	jmp    80106f58 <alltraps>

80107e20 <vector210>:
.globl vector210
vector210:
  pushl $0
80107e20:	6a 00                	push   $0x0
  pushl $210
80107e22:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107e27:	e9 2c f1 ff ff       	jmp    80106f58 <alltraps>

80107e2c <vector211>:
.globl vector211
vector211:
  pushl $0
80107e2c:	6a 00                	push   $0x0
  pushl $211
80107e2e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107e33:	e9 20 f1 ff ff       	jmp    80106f58 <alltraps>

80107e38 <vector212>:
.globl vector212
vector212:
  pushl $0
80107e38:	6a 00                	push   $0x0
  pushl $212
80107e3a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107e3f:	e9 14 f1 ff ff       	jmp    80106f58 <alltraps>

80107e44 <vector213>:
.globl vector213
vector213:
  pushl $0
80107e44:	6a 00                	push   $0x0
  pushl $213
80107e46:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107e4b:	e9 08 f1 ff ff       	jmp    80106f58 <alltraps>

80107e50 <vector214>:
.globl vector214
vector214:
  pushl $0
80107e50:	6a 00                	push   $0x0
  pushl $214
80107e52:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107e57:	e9 fc f0 ff ff       	jmp    80106f58 <alltraps>

80107e5c <vector215>:
.globl vector215
vector215:
  pushl $0
80107e5c:	6a 00                	push   $0x0
  pushl $215
80107e5e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107e63:	e9 f0 f0 ff ff       	jmp    80106f58 <alltraps>

80107e68 <vector216>:
.globl vector216
vector216:
  pushl $0
80107e68:	6a 00                	push   $0x0
  pushl $216
80107e6a:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107e6f:	e9 e4 f0 ff ff       	jmp    80106f58 <alltraps>

80107e74 <vector217>:
.globl vector217
vector217:
  pushl $0
80107e74:	6a 00                	push   $0x0
  pushl $217
80107e76:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107e7b:	e9 d8 f0 ff ff       	jmp    80106f58 <alltraps>

80107e80 <vector218>:
.globl vector218
vector218:
  pushl $0
80107e80:	6a 00                	push   $0x0
  pushl $218
80107e82:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107e87:	e9 cc f0 ff ff       	jmp    80106f58 <alltraps>

80107e8c <vector219>:
.globl vector219
vector219:
  pushl $0
80107e8c:	6a 00                	push   $0x0
  pushl $219
80107e8e:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107e93:	e9 c0 f0 ff ff       	jmp    80106f58 <alltraps>

80107e98 <vector220>:
.globl vector220
vector220:
  pushl $0
80107e98:	6a 00                	push   $0x0
  pushl $220
80107e9a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107e9f:	e9 b4 f0 ff ff       	jmp    80106f58 <alltraps>

80107ea4 <vector221>:
.globl vector221
vector221:
  pushl $0
80107ea4:	6a 00                	push   $0x0
  pushl $221
80107ea6:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107eab:	e9 a8 f0 ff ff       	jmp    80106f58 <alltraps>

80107eb0 <vector222>:
.globl vector222
vector222:
  pushl $0
80107eb0:	6a 00                	push   $0x0
  pushl $222
80107eb2:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107eb7:	e9 9c f0 ff ff       	jmp    80106f58 <alltraps>

80107ebc <vector223>:
.globl vector223
vector223:
  pushl $0
80107ebc:	6a 00                	push   $0x0
  pushl $223
80107ebe:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107ec3:	e9 90 f0 ff ff       	jmp    80106f58 <alltraps>

80107ec8 <vector224>:
.globl vector224
vector224:
  pushl $0
80107ec8:	6a 00                	push   $0x0
  pushl $224
80107eca:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107ecf:	e9 84 f0 ff ff       	jmp    80106f58 <alltraps>

80107ed4 <vector225>:
.globl vector225
vector225:
  pushl $0
80107ed4:	6a 00                	push   $0x0
  pushl $225
80107ed6:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107edb:	e9 78 f0 ff ff       	jmp    80106f58 <alltraps>

80107ee0 <vector226>:
.globl vector226
vector226:
  pushl $0
80107ee0:	6a 00                	push   $0x0
  pushl $226
80107ee2:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107ee7:	e9 6c f0 ff ff       	jmp    80106f58 <alltraps>

80107eec <vector227>:
.globl vector227
vector227:
  pushl $0
80107eec:	6a 00                	push   $0x0
  pushl $227
80107eee:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107ef3:	e9 60 f0 ff ff       	jmp    80106f58 <alltraps>

80107ef8 <vector228>:
.globl vector228
vector228:
  pushl $0
80107ef8:	6a 00                	push   $0x0
  pushl $228
80107efa:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107eff:	e9 54 f0 ff ff       	jmp    80106f58 <alltraps>

80107f04 <vector229>:
.globl vector229
vector229:
  pushl $0
80107f04:	6a 00                	push   $0x0
  pushl $229
80107f06:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107f0b:	e9 48 f0 ff ff       	jmp    80106f58 <alltraps>

80107f10 <vector230>:
.globl vector230
vector230:
  pushl $0
80107f10:	6a 00                	push   $0x0
  pushl $230
80107f12:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107f17:	e9 3c f0 ff ff       	jmp    80106f58 <alltraps>

80107f1c <vector231>:
.globl vector231
vector231:
  pushl $0
80107f1c:	6a 00                	push   $0x0
  pushl $231
80107f1e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107f23:	e9 30 f0 ff ff       	jmp    80106f58 <alltraps>

80107f28 <vector232>:
.globl vector232
vector232:
  pushl $0
80107f28:	6a 00                	push   $0x0
  pushl $232
80107f2a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107f2f:	e9 24 f0 ff ff       	jmp    80106f58 <alltraps>

80107f34 <vector233>:
.globl vector233
vector233:
  pushl $0
80107f34:	6a 00                	push   $0x0
  pushl $233
80107f36:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107f3b:	e9 18 f0 ff ff       	jmp    80106f58 <alltraps>

80107f40 <vector234>:
.globl vector234
vector234:
  pushl $0
80107f40:	6a 00                	push   $0x0
  pushl $234
80107f42:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107f47:	e9 0c f0 ff ff       	jmp    80106f58 <alltraps>

80107f4c <vector235>:
.globl vector235
vector235:
  pushl $0
80107f4c:	6a 00                	push   $0x0
  pushl $235
80107f4e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107f53:	e9 00 f0 ff ff       	jmp    80106f58 <alltraps>

80107f58 <vector236>:
.globl vector236
vector236:
  pushl $0
80107f58:	6a 00                	push   $0x0
  pushl $236
80107f5a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107f5f:	e9 f4 ef ff ff       	jmp    80106f58 <alltraps>

80107f64 <vector237>:
.globl vector237
vector237:
  pushl $0
80107f64:	6a 00                	push   $0x0
  pushl $237
80107f66:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107f6b:	e9 e8 ef ff ff       	jmp    80106f58 <alltraps>

80107f70 <vector238>:
.globl vector238
vector238:
  pushl $0
80107f70:	6a 00                	push   $0x0
  pushl $238
80107f72:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107f77:	e9 dc ef ff ff       	jmp    80106f58 <alltraps>

80107f7c <vector239>:
.globl vector239
vector239:
  pushl $0
80107f7c:	6a 00                	push   $0x0
  pushl $239
80107f7e:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107f83:	e9 d0 ef ff ff       	jmp    80106f58 <alltraps>

80107f88 <vector240>:
.globl vector240
vector240:
  pushl $0
80107f88:	6a 00                	push   $0x0
  pushl $240
80107f8a:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107f8f:	e9 c4 ef ff ff       	jmp    80106f58 <alltraps>

80107f94 <vector241>:
.globl vector241
vector241:
  pushl $0
80107f94:	6a 00                	push   $0x0
  pushl $241
80107f96:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107f9b:	e9 b8 ef ff ff       	jmp    80106f58 <alltraps>

80107fa0 <vector242>:
.globl vector242
vector242:
  pushl $0
80107fa0:	6a 00                	push   $0x0
  pushl $242
80107fa2:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107fa7:	e9 ac ef ff ff       	jmp    80106f58 <alltraps>

80107fac <vector243>:
.globl vector243
vector243:
  pushl $0
80107fac:	6a 00                	push   $0x0
  pushl $243
80107fae:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107fb3:	e9 a0 ef ff ff       	jmp    80106f58 <alltraps>

80107fb8 <vector244>:
.globl vector244
vector244:
  pushl $0
80107fb8:	6a 00                	push   $0x0
  pushl $244
80107fba:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107fbf:	e9 94 ef ff ff       	jmp    80106f58 <alltraps>

80107fc4 <vector245>:
.globl vector245
vector245:
  pushl $0
80107fc4:	6a 00                	push   $0x0
  pushl $245
80107fc6:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107fcb:	e9 88 ef ff ff       	jmp    80106f58 <alltraps>

80107fd0 <vector246>:
.globl vector246
vector246:
  pushl $0
80107fd0:	6a 00                	push   $0x0
  pushl $246
80107fd2:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107fd7:	e9 7c ef ff ff       	jmp    80106f58 <alltraps>

80107fdc <vector247>:
.globl vector247
vector247:
  pushl $0
80107fdc:	6a 00                	push   $0x0
  pushl $247
80107fde:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107fe3:	e9 70 ef ff ff       	jmp    80106f58 <alltraps>

80107fe8 <vector248>:
.globl vector248
vector248:
  pushl $0
80107fe8:	6a 00                	push   $0x0
  pushl $248
80107fea:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107fef:	e9 64 ef ff ff       	jmp    80106f58 <alltraps>

80107ff4 <vector249>:
.globl vector249
vector249:
  pushl $0
80107ff4:	6a 00                	push   $0x0
  pushl $249
80107ff6:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107ffb:	e9 58 ef ff ff       	jmp    80106f58 <alltraps>

80108000 <vector250>:
.globl vector250
vector250:
  pushl $0
80108000:	6a 00                	push   $0x0
  pushl $250
80108002:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108007:	e9 4c ef ff ff       	jmp    80106f58 <alltraps>

8010800c <vector251>:
.globl vector251
vector251:
  pushl $0
8010800c:	6a 00                	push   $0x0
  pushl $251
8010800e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108013:	e9 40 ef ff ff       	jmp    80106f58 <alltraps>

80108018 <vector252>:
.globl vector252
vector252:
  pushl $0
80108018:	6a 00                	push   $0x0
  pushl $252
8010801a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010801f:	e9 34 ef ff ff       	jmp    80106f58 <alltraps>

80108024 <vector253>:
.globl vector253
vector253:
  pushl $0
80108024:	6a 00                	push   $0x0
  pushl $253
80108026:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010802b:	e9 28 ef ff ff       	jmp    80106f58 <alltraps>

80108030 <vector254>:
.globl vector254
vector254:
  pushl $0
80108030:	6a 00                	push   $0x0
  pushl $254
80108032:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108037:	e9 1c ef ff ff       	jmp    80106f58 <alltraps>

8010803c <vector255>:
.globl vector255
vector255:
  pushl $0
8010803c:	6a 00                	push   $0x0
  pushl $255
8010803e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108043:	e9 10 ef ff ff       	jmp    80106f58 <alltraps>

80108048 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108048:	55                   	push   %ebp
80108049:	89 e5                	mov    %esp,%ebp
8010804b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010804e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108051:	83 e8 01             	sub    $0x1,%eax
80108054:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108058:	8b 45 08             	mov    0x8(%ebp),%eax
8010805b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010805f:	8b 45 08             	mov    0x8(%ebp),%eax
80108062:	c1 e8 10             	shr    $0x10,%eax
80108065:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108069:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010806c:	0f 01 10             	lgdtl  (%eax)
}
8010806f:	c9                   	leave  
80108070:	c3                   	ret    

80108071 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108071:	55                   	push   %ebp
80108072:	89 e5                	mov    %esp,%ebp
80108074:	83 ec 04             	sub    $0x4,%esp
80108077:	8b 45 08             	mov    0x8(%ebp),%eax
8010807a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010807e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108082:	0f 00 d8             	ltr    %ax
}
80108085:	c9                   	leave  
80108086:	c3                   	ret    

80108087 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108087:	55                   	push   %ebp
80108088:	89 e5                	mov    %esp,%ebp
8010808a:	83 ec 04             	sub    $0x4,%esp
8010808d:	8b 45 08             	mov    0x8(%ebp),%eax
80108090:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108094:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108098:	8e e8                	mov    %eax,%gs
}
8010809a:	c9                   	leave  
8010809b:	c3                   	ret    

8010809c <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010809c:	55                   	push   %ebp
8010809d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010809f:	8b 45 08             	mov    0x8(%ebp),%eax
801080a2:	0f 22 d8             	mov    %eax,%cr3
}
801080a5:	5d                   	pop    %ebp
801080a6:	c3                   	ret    

801080a7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801080a7:	55                   	push   %ebp
801080a8:	89 e5                	mov    %esp,%ebp
801080aa:	8b 45 08             	mov    0x8(%ebp),%eax
801080ad:	05 00 00 00 80       	add    $0x80000000,%eax
801080b2:	5d                   	pop    %ebp
801080b3:	c3                   	ret    

801080b4 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801080b4:	55                   	push   %ebp
801080b5:	89 e5                	mov    %esp,%ebp
801080b7:	8b 45 08             	mov    0x8(%ebp),%eax
801080ba:	05 00 00 00 80       	add    $0x80000000,%eax
801080bf:	5d                   	pop    %ebp
801080c0:	c3                   	ret    

801080c1 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801080c1:	55                   	push   %ebp
801080c2:	89 e5                	mov    %esp,%ebp
801080c4:	53                   	push   %ebx
801080c5:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801080c8:	e8 a7 b5 ff ff       	call   80103674 <cpunum>
801080cd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801080d3:	05 80 3b 11 80       	add    $0x80113b80,%eax
801080d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801080db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080de:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801080e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e7:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801080ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f0:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801080f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801080fb:	83 e2 f0             	and    $0xfffffff0,%edx
801080fe:	83 ca 0a             	or     $0xa,%edx
80108101:	88 50 7d             	mov    %dl,0x7d(%eax)
80108104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108107:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010810b:	83 ca 10             	or     $0x10,%edx
8010810e:	88 50 7d             	mov    %dl,0x7d(%eax)
80108111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108114:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108118:	83 e2 9f             	and    $0xffffff9f,%edx
8010811b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010811e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108121:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108125:	83 ca 80             	or     $0xffffff80,%edx
80108128:	88 50 7d             	mov    %dl,0x7d(%eax)
8010812b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108132:	83 ca 0f             	or     $0xf,%edx
80108135:	88 50 7e             	mov    %dl,0x7e(%eax)
80108138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010813f:	83 e2 ef             	and    $0xffffffef,%edx
80108142:	88 50 7e             	mov    %dl,0x7e(%eax)
80108145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108148:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010814c:	83 e2 df             	and    $0xffffffdf,%edx
8010814f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108155:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108159:	83 ca 40             	or     $0x40,%edx
8010815c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010815f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108162:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108166:	83 ca 80             	or     $0xffffff80,%edx
80108169:	88 50 7e             	mov    %dl,0x7e(%eax)
8010816c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108176:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010817d:	ff ff 
8010817f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108182:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108189:	00 00 
8010818b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108198:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010819f:	83 e2 f0             	and    $0xfffffff0,%edx
801081a2:	83 ca 02             	or     $0x2,%edx
801081a5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801081ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ae:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801081b5:	83 ca 10             	or     $0x10,%edx
801081b8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801081be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801081c8:	83 e2 9f             	and    $0xffffff9f,%edx
801081cb:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801081d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801081db:	83 ca 80             	or     $0xffffff80,%edx
801081de:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801081e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801081ee:	83 ca 0f             	or     $0xf,%edx
801081f1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fa:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108201:	83 e2 ef             	and    $0xffffffef,%edx
80108204:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010820a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108214:	83 e2 df             	and    $0xffffffdf,%edx
80108217:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010821d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108220:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108227:	83 ca 40             	or     $0x40,%edx
8010822a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108233:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010823a:	83 ca 80             	or     $0xffffff80,%edx
8010823d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108246:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010824d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108250:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108257:	ff ff 
80108259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825c:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108263:	00 00 
80108265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108268:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010826f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108272:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108279:	83 e2 f0             	and    $0xfffffff0,%edx
8010827c:	83 ca 0a             	or     $0xa,%edx
8010827f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108288:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010828f:	83 ca 10             	or     $0x10,%edx
80108292:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010829b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801082a2:	83 ca 60             	or     $0x60,%edx
801082a5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801082ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ae:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801082b5:	83 ca 80             	or     $0xffffff80,%edx
801082b8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801082be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801082c8:	83 ca 0f             	or     $0xf,%edx
801082cb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801082d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801082db:	83 e2 ef             	and    $0xffffffef,%edx
801082de:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801082e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801082ee:	83 e2 df             	and    $0xffffffdf,%edx
801082f1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801082f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082fa:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108301:	83 ca 40             	or     $0x40,%edx
80108304:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010830a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108314:	83 ca 80             	or     $0xffffff80,%edx
80108317:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010831d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108320:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832a:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108331:	ff ff 
80108333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108336:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
8010833d:	00 00 
8010833f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108342:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108353:	83 e2 f0             	and    $0xfffffff0,%edx
80108356:	83 ca 02             	or     $0x2,%edx
80108359:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010835f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108362:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108369:	83 ca 10             	or     $0x10,%edx
8010836c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108375:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010837c:	83 ca 60             	or     $0x60,%edx
8010837f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108388:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010838f:	83 ca 80             	or     $0xffffff80,%edx
80108392:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801083a2:	83 ca 0f             	or     $0xf,%edx
801083a5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801083ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ae:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801083b5:	83 e2 ef             	and    $0xffffffef,%edx
801083b8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801083be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801083c8:	83 e2 df             	and    $0xffffffdf,%edx
801083cb:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801083d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801083db:	83 ca 40             	or     $0x40,%edx
801083de:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801083e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801083ee:	83 ca 80             	or     $0xffffff80,%edx
801083f1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801083f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fa:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108404:	05 b4 00 00 00       	add    $0xb4,%eax
80108409:	89 c3                	mov    %eax,%ebx
8010840b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840e:	05 b4 00 00 00       	add    $0xb4,%eax
80108413:	c1 e8 10             	shr    $0x10,%eax
80108416:	89 c1                	mov    %eax,%ecx
80108418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841b:	05 b4 00 00 00       	add    $0xb4,%eax
80108420:	c1 e8 18             	shr    $0x18,%eax
80108423:	89 c2                	mov    %eax,%edx
80108425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108428:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010842f:	00 00 
80108431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108434:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010843b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843e:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80108444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108447:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010844e:	83 e1 f0             	and    $0xfffffff0,%ecx
80108451:	83 c9 02             	or     $0x2,%ecx
80108454:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010845a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845d:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108464:	83 c9 10             	or     $0x10,%ecx
80108467:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010846d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108470:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108477:	83 e1 9f             	and    $0xffffff9f,%ecx
8010847a:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108483:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010848a:	83 c9 80             	or     $0xffffff80,%ecx
8010848d:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108496:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010849d:	83 e1 f0             	and    $0xfffffff0,%ecx
801084a0:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801084a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a9:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801084b0:	83 e1 ef             	and    $0xffffffef,%ecx
801084b3:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801084b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bc:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801084c3:	83 e1 df             	and    $0xffffffdf,%ecx
801084c6:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801084cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cf:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801084d6:	83 c9 40             	or     $0x40,%ecx
801084d9:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801084df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e2:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801084e9:	83 c9 80             	or     $0xffffff80,%ecx
801084ec:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801084f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f5:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801084fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fe:	83 c0 70             	add    $0x70,%eax
80108501:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80108508:	00 
80108509:	89 04 24             	mov    %eax,(%esp)
8010850c:	e8 37 fb ff ff       	call   80108048 <lgdt>
  loadgs(SEG_KCPU << 3);
80108511:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108518:	e8 6a fb ff ff       	call   80108087 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
8010851d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108520:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108526:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010852d:	00 00 00 00 
}
80108531:	83 c4 24             	add    $0x24,%esp
80108534:	5b                   	pop    %ebx
80108535:	5d                   	pop    %ebp
80108536:	c3                   	ret    

80108537 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108537:	55                   	push   %ebp
80108538:	89 e5                	mov    %esp,%ebp
8010853a:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010853d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108540:	c1 e8 16             	shr    $0x16,%eax
80108543:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010854a:	8b 45 08             	mov    0x8(%ebp),%eax
8010854d:	01 d0                	add    %edx,%eax
8010854f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108555:	8b 00                	mov    (%eax),%eax
80108557:	83 e0 01             	and    $0x1,%eax
8010855a:	85 c0                	test   %eax,%eax
8010855c:	74 17                	je     80108575 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
8010855e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108561:	8b 00                	mov    (%eax),%eax
80108563:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108568:	89 04 24             	mov    %eax,(%esp)
8010856b:	e8 44 fb ff ff       	call   801080b4 <p2v>
80108570:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108573:	eb 4b                	jmp    801085c0 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108575:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108579:	74 0e                	je     80108589 <walkpgdir+0x52>
8010857b:	e8 5e ad ff ff       	call   801032de <kalloc>
80108580:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108583:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108587:	75 07                	jne    80108590 <walkpgdir+0x59>
      return 0;
80108589:	b8 00 00 00 00       	mov    $0x0,%eax
8010858e:	eb 47                	jmp    801085d7 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108590:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108597:	00 
80108598:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010859f:	00 
801085a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a3:	89 04 24             	mov    %eax,(%esp)
801085a6:	e8 83 d4 ff ff       	call   80105a2e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801085ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ae:	89 04 24             	mov    %eax,(%esp)
801085b1:	e8 f1 fa ff ff       	call   801080a7 <v2p>
801085b6:	83 c8 07             	or     $0x7,%eax
801085b9:	89 c2                	mov    %eax,%edx
801085bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085be:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801085c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801085c3:	c1 e8 0c             	shr    $0xc,%eax
801085c6:	25 ff 03 00 00       	and    $0x3ff,%eax
801085cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d5:	01 d0                	add    %edx,%eax
}
801085d7:	c9                   	leave  
801085d8:	c3                   	ret    

801085d9 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801085d9:	55                   	push   %ebp
801085da:	89 e5                	mov    %esp,%ebp
801085dc:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
801085df:	8b 45 0c             	mov    0xc(%ebp),%eax
801085e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801085ea:	8b 55 0c             	mov    0xc(%ebp),%edx
801085ed:	8b 45 10             	mov    0x10(%ebp),%eax
801085f0:	01 d0                	add    %edx,%eax
801085f2:	83 e8 01             	sub    $0x1,%eax
801085f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801085fd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108604:	00 
80108605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108608:	89 44 24 04          	mov    %eax,0x4(%esp)
8010860c:	8b 45 08             	mov    0x8(%ebp),%eax
8010860f:	89 04 24             	mov    %eax,(%esp)
80108612:	e8 20 ff ff ff       	call   80108537 <walkpgdir>
80108617:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010861a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010861e:	75 07                	jne    80108627 <mappages+0x4e>
      return -1;
80108620:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108625:	eb 48                	jmp    8010866f <mappages+0x96>
    if(*pte & PTE_P)
80108627:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010862a:	8b 00                	mov    (%eax),%eax
8010862c:	83 e0 01             	and    $0x1,%eax
8010862f:	85 c0                	test   %eax,%eax
80108631:	74 0c                	je     8010863f <mappages+0x66>
      panic("remap");
80108633:	c7 04 24 e8 94 10 80 	movl   $0x801094e8,(%esp)
8010863a:	e8 fb 7e ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
8010863f:	8b 45 18             	mov    0x18(%ebp),%eax
80108642:	0b 45 14             	or     0x14(%ebp),%eax
80108645:	83 c8 01             	or     $0x1,%eax
80108648:	89 c2                	mov    %eax,%edx
8010864a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010864d:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010864f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108652:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108655:	75 08                	jne    8010865f <mappages+0x86>
      break;
80108657:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108658:	b8 00 00 00 00       	mov    $0x0,%eax
8010865d:	eb 10                	jmp    8010866f <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
8010865f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108666:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010866d:	eb 8e                	jmp    801085fd <mappages+0x24>
  return 0;
}
8010866f:	c9                   	leave  
80108670:	c3                   	ret    

80108671 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108671:	55                   	push   %ebp
80108672:	89 e5                	mov    %esp,%ebp
80108674:	53                   	push   %ebx
80108675:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108678:	e8 61 ac ff ff       	call   801032de <kalloc>
8010867d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108680:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108684:	75 0a                	jne    80108690 <setupkvm+0x1f>
    return 0;
80108686:	b8 00 00 00 00       	mov    $0x0,%eax
8010868b:	e9 98 00 00 00       	jmp    80108728 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108690:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108697:	00 
80108698:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010869f:	00 
801086a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086a3:	89 04 24             	mov    %eax,(%esp)
801086a6:	e8 83 d3 ff ff       	call   80105a2e <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801086ab:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801086b2:	e8 fd f9 ff ff       	call   801080b4 <p2v>
801086b7:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801086bc:	76 0c                	jbe    801086ca <setupkvm+0x59>
    panic("PHYSTOP too high");
801086be:	c7 04 24 ee 94 10 80 	movl   $0x801094ee,(%esp)
801086c5:	e8 70 7e ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801086ca:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
801086d1:	eb 49                	jmp    8010871c <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801086d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d6:	8b 48 0c             	mov    0xc(%eax),%ecx
801086d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086dc:	8b 50 04             	mov    0x4(%eax),%edx
801086df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e2:	8b 58 08             	mov    0x8(%eax),%ebx
801086e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e8:	8b 40 04             	mov    0x4(%eax),%eax
801086eb:	29 c3                	sub    %eax,%ebx
801086ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f0:	8b 00                	mov    (%eax),%eax
801086f2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801086f6:	89 54 24 0c          	mov    %edx,0xc(%esp)
801086fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801086fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80108702:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108705:	89 04 24             	mov    %eax,(%esp)
80108708:	e8 cc fe ff ff       	call   801085d9 <mappages>
8010870d:	85 c0                	test   %eax,%eax
8010870f:	79 07                	jns    80108718 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108711:	b8 00 00 00 00       	mov    $0x0,%eax
80108716:	eb 10                	jmp    80108728 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108718:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010871c:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108723:	72 ae                	jb     801086d3 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108725:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108728:	83 c4 34             	add    $0x34,%esp
8010872b:	5b                   	pop    %ebx
8010872c:	5d                   	pop    %ebp
8010872d:	c3                   	ret    

8010872e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010872e:	55                   	push   %ebp
8010872f:	89 e5                	mov    %esp,%ebp
80108731:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108734:	e8 38 ff ff ff       	call   80108671 <setupkvm>
80108739:	a3 58 6d 11 80       	mov    %eax,0x80116d58
  switchkvm();
8010873e:	e8 02 00 00 00       	call   80108745 <switchkvm>
}
80108743:	c9                   	leave  
80108744:	c3                   	ret    

80108745 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108745:	55                   	push   %ebp
80108746:	89 e5                	mov    %esp,%ebp
80108748:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010874b:	a1 58 6d 11 80       	mov    0x80116d58,%eax
80108750:	89 04 24             	mov    %eax,(%esp)
80108753:	e8 4f f9 ff ff       	call   801080a7 <v2p>
80108758:	89 04 24             	mov    %eax,(%esp)
8010875b:	e8 3c f9 ff ff       	call   8010809c <lcr3>
}
80108760:	c9                   	leave  
80108761:	c3                   	ret    

80108762 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108762:	55                   	push   %ebp
80108763:	89 e5                	mov    %esp,%ebp
80108765:	53                   	push   %ebx
80108766:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108769:	e8 c0 d1 ff ff       	call   8010592e <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010876e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108774:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010877b:	83 c2 08             	add    $0x8,%edx
8010877e:	89 d3                	mov    %edx,%ebx
80108780:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108787:	83 c2 08             	add    $0x8,%edx
8010878a:	c1 ea 10             	shr    $0x10,%edx
8010878d:	89 d1                	mov    %edx,%ecx
8010878f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108796:	83 c2 08             	add    $0x8,%edx
80108799:	c1 ea 18             	shr    $0x18,%edx
8010879c:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801087a3:	67 00 
801087a5:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
801087ac:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
801087b2:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801087b9:	83 e1 f0             	and    $0xfffffff0,%ecx
801087bc:	83 c9 09             	or     $0x9,%ecx
801087bf:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801087c5:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801087cc:	83 c9 10             	or     $0x10,%ecx
801087cf:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801087d5:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801087dc:	83 e1 9f             	and    $0xffffff9f,%ecx
801087df:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801087e5:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801087ec:	83 c9 80             	or     $0xffffff80,%ecx
801087ef:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801087f5:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801087fc:	83 e1 f0             	and    $0xfffffff0,%ecx
801087ff:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108805:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010880c:	83 e1 ef             	and    $0xffffffef,%ecx
8010880f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108815:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010881c:	83 e1 df             	and    $0xffffffdf,%ecx
8010881f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108825:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010882c:	83 c9 40             	or     $0x40,%ecx
8010882f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108835:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010883c:	83 e1 7f             	and    $0x7f,%ecx
8010883f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108845:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010884b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108851:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108858:	83 e2 ef             	and    $0xffffffef,%edx
8010885b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108861:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108867:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
8010886d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108873:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010887a:	8b 52 08             	mov    0x8(%edx),%edx
8010887d:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108883:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108886:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
8010888d:	e8 df f7 ff ff       	call   80108071 <ltr>
  if(p->pgdir == 0)
80108892:	8b 45 08             	mov    0x8(%ebp),%eax
80108895:	8b 40 04             	mov    0x4(%eax),%eax
80108898:	85 c0                	test   %eax,%eax
8010889a:	75 0c                	jne    801088a8 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
8010889c:	c7 04 24 ff 94 10 80 	movl   $0x801094ff,(%esp)
801088a3:	e8 92 7c ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801088a8:	8b 45 08             	mov    0x8(%ebp),%eax
801088ab:	8b 40 04             	mov    0x4(%eax),%eax
801088ae:	89 04 24             	mov    %eax,(%esp)
801088b1:	e8 f1 f7 ff ff       	call   801080a7 <v2p>
801088b6:	89 04 24             	mov    %eax,(%esp)
801088b9:	e8 de f7 ff ff       	call   8010809c <lcr3>
  popcli();
801088be:	e8 af d0 ff ff       	call   80105972 <popcli>
}
801088c3:	83 c4 14             	add    $0x14,%esp
801088c6:	5b                   	pop    %ebx
801088c7:	5d                   	pop    %ebp
801088c8:	c3                   	ret    

801088c9 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801088c9:	55                   	push   %ebp
801088ca:	89 e5                	mov    %esp,%ebp
801088cc:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801088cf:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801088d6:	76 0c                	jbe    801088e4 <inituvm+0x1b>
    panic("inituvm: more than a page");
801088d8:	c7 04 24 13 95 10 80 	movl   $0x80109513,(%esp)
801088df:	e8 56 7c ff ff       	call   8010053a <panic>
  mem = kalloc();
801088e4:	e8 f5 a9 ff ff       	call   801032de <kalloc>
801088e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801088ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801088f3:	00 
801088f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801088fb:	00 
801088fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ff:	89 04 24             	mov    %eax,(%esp)
80108902:	e8 27 d1 ff ff       	call   80105a2e <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890a:	89 04 24             	mov    %eax,(%esp)
8010890d:	e8 95 f7 ff ff       	call   801080a7 <v2p>
80108912:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108919:	00 
8010891a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010891e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108925:	00 
80108926:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010892d:	00 
8010892e:	8b 45 08             	mov    0x8(%ebp),%eax
80108931:	89 04 24             	mov    %eax,(%esp)
80108934:	e8 a0 fc ff ff       	call   801085d9 <mappages>
  memmove(mem, init, sz);
80108939:	8b 45 10             	mov    0x10(%ebp),%eax
8010893c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108940:	8b 45 0c             	mov    0xc(%ebp),%eax
80108943:	89 44 24 04          	mov    %eax,0x4(%esp)
80108947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010894a:	89 04 24             	mov    %eax,(%esp)
8010894d:	e8 ab d1 ff ff       	call   80105afd <memmove>
}
80108952:	c9                   	leave  
80108953:	c3                   	ret    

80108954 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108954:	55                   	push   %ebp
80108955:	89 e5                	mov    %esp,%ebp
80108957:	53                   	push   %ebx
80108958:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010895b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010895e:	25 ff 0f 00 00       	and    $0xfff,%eax
80108963:	85 c0                	test   %eax,%eax
80108965:	74 0c                	je     80108973 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108967:	c7 04 24 30 95 10 80 	movl   $0x80109530,(%esp)
8010896e:	e8 c7 7b ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108973:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010897a:	e9 a9 00 00 00       	jmp    80108a28 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010897f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108982:	8b 55 0c             	mov    0xc(%ebp),%edx
80108985:	01 d0                	add    %edx,%eax
80108987:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010898e:	00 
8010898f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108993:	8b 45 08             	mov    0x8(%ebp),%eax
80108996:	89 04 24             	mov    %eax,(%esp)
80108999:	e8 99 fb ff ff       	call   80108537 <walkpgdir>
8010899e:	89 45 ec             	mov    %eax,-0x14(%ebp)
801089a1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801089a5:	75 0c                	jne    801089b3 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801089a7:	c7 04 24 53 95 10 80 	movl   $0x80109553,(%esp)
801089ae:	e8 87 7b ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801089b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089b6:	8b 00                	mov    (%eax),%eax
801089b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801089c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c3:	8b 55 18             	mov    0x18(%ebp),%edx
801089c6:	29 c2                	sub    %eax,%edx
801089c8:	89 d0                	mov    %edx,%eax
801089ca:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801089cf:	77 0f                	ja     801089e0 <loaduvm+0x8c>
      n = sz - i;
801089d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d4:	8b 55 18             	mov    0x18(%ebp),%edx
801089d7:	29 c2                	sub    %eax,%edx
801089d9:	89 d0                	mov    %edx,%eax
801089db:	89 45 f0             	mov    %eax,-0x10(%ebp)
801089de:	eb 07                	jmp    801089e7 <loaduvm+0x93>
    else
      n = PGSIZE;
801089e0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801089e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ea:	8b 55 14             	mov    0x14(%ebp),%edx
801089ed:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801089f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089f3:	89 04 24             	mov    %eax,(%esp)
801089f6:	e8 b9 f6 ff ff       	call   801080b4 <p2v>
801089fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801089fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108a02:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108a06:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a0a:	8b 45 10             	mov    0x10(%ebp),%eax
80108a0d:	89 04 24             	mov    %eax,(%esp)
80108a10:	e8 18 9b ff ff       	call   8010252d <readi>
80108a15:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108a18:	74 07                	je     80108a21 <loaduvm+0xcd>
      return -1;
80108a1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a1f:	eb 18                	jmp    80108a39 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108a21:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2b:	3b 45 18             	cmp    0x18(%ebp),%eax
80108a2e:	0f 82 4b ff ff ff    	jb     8010897f <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a39:	83 c4 24             	add    $0x24,%esp
80108a3c:	5b                   	pop    %ebx
80108a3d:	5d                   	pop    %ebp
80108a3e:	c3                   	ret    

80108a3f <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108a3f:	55                   	push   %ebp
80108a40:	89 e5                	mov    %esp,%ebp
80108a42:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108a45:	8b 45 10             	mov    0x10(%ebp),%eax
80108a48:	85 c0                	test   %eax,%eax
80108a4a:	79 0a                	jns    80108a56 <allocuvm+0x17>
    return 0;
80108a4c:	b8 00 00 00 00       	mov    $0x0,%eax
80108a51:	e9 c1 00 00 00       	jmp    80108b17 <allocuvm+0xd8>
  if(newsz < oldsz)
80108a56:	8b 45 10             	mov    0x10(%ebp),%eax
80108a59:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108a5c:	73 08                	jae    80108a66 <allocuvm+0x27>
    return oldsz;
80108a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a61:	e9 b1 00 00 00       	jmp    80108b17 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108a66:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a69:	05 ff 0f 00 00       	add    $0xfff,%eax
80108a6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108a76:	e9 8d 00 00 00       	jmp    80108b08 <allocuvm+0xc9>
    mem = kalloc();
80108a7b:	e8 5e a8 ff ff       	call   801032de <kalloc>
80108a80:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108a83:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a87:	75 2c                	jne    80108ab5 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108a89:	c7 04 24 71 95 10 80 	movl   $0x80109571,(%esp)
80108a90:	e8 0b 79 ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108a95:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a98:	89 44 24 08          	mov    %eax,0x8(%esp)
80108a9c:	8b 45 10             	mov    0x10(%ebp),%eax
80108a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80108aa6:	89 04 24             	mov    %eax,(%esp)
80108aa9:	e8 6b 00 00 00       	call   80108b19 <deallocuvm>
      return 0;
80108aae:	b8 00 00 00 00       	mov    $0x0,%eax
80108ab3:	eb 62                	jmp    80108b17 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108ab5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108abc:	00 
80108abd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108ac4:	00 
80108ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ac8:	89 04 24             	mov    %eax,(%esp)
80108acb:	e8 5e cf ff ff       	call   80105a2e <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ad3:	89 04 24             	mov    %eax,(%esp)
80108ad6:	e8 cc f5 ff ff       	call   801080a7 <v2p>
80108adb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108ade:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108ae5:	00 
80108ae6:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108aea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108af1:	00 
80108af2:	89 54 24 04          	mov    %edx,0x4(%esp)
80108af6:	8b 45 08             	mov    0x8(%ebp),%eax
80108af9:	89 04 24             	mov    %eax,(%esp)
80108afc:	e8 d8 fa ff ff       	call   801085d9 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108b01:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0b:	3b 45 10             	cmp    0x10(%ebp),%eax
80108b0e:	0f 82 67 ff ff ff    	jb     80108a7b <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108b14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108b17:	c9                   	leave  
80108b18:	c3                   	ret    

80108b19 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108b19:	55                   	push   %ebp
80108b1a:	89 e5                	mov    %esp,%ebp
80108b1c:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108b1f:	8b 45 10             	mov    0x10(%ebp),%eax
80108b22:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b25:	72 08                	jb     80108b2f <deallocuvm+0x16>
    return oldsz;
80108b27:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b2a:	e9 a4 00 00 00       	jmp    80108bd3 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108b2f:	8b 45 10             	mov    0x10(%ebp),%eax
80108b32:	05 ff 0f 00 00       	add    $0xfff,%eax
80108b37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108b3f:	e9 80 00 00 00       	jmp    80108bc4 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b4e:	00 
80108b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b53:	8b 45 08             	mov    0x8(%ebp),%eax
80108b56:	89 04 24             	mov    %eax,(%esp)
80108b59:	e8 d9 f9 ff ff       	call   80108537 <walkpgdir>
80108b5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108b61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b65:	75 09                	jne    80108b70 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108b67:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108b6e:	eb 4d                	jmp    80108bbd <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108b70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b73:	8b 00                	mov    (%eax),%eax
80108b75:	83 e0 01             	and    $0x1,%eax
80108b78:	85 c0                	test   %eax,%eax
80108b7a:	74 41                	je     80108bbd <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b7f:	8b 00                	mov    (%eax),%eax
80108b81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b86:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108b89:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b8d:	75 0c                	jne    80108b9b <deallocuvm+0x82>
        panic("kfree");
80108b8f:	c7 04 24 89 95 10 80 	movl   $0x80109589,(%esp)
80108b96:	e8 9f 79 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108b9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b9e:	89 04 24             	mov    %eax,(%esp)
80108ba1:	e8 0e f5 ff ff       	call   801080b4 <p2v>
80108ba6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108ba9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bac:	89 04 24             	mov    %eax,(%esp)
80108baf:	e8 91 a6 ff ff       	call   80103245 <kfree>
      *pte = 0;
80108bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bb7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108bbd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bc7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108bca:	0f 82 74 ff ff ff    	jb     80108b44 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108bd0:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108bd3:	c9                   	leave  
80108bd4:	c3                   	ret    

80108bd5 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108bd5:	55                   	push   %ebp
80108bd6:	89 e5                	mov    %esp,%ebp
80108bd8:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108bdb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108bdf:	75 0c                	jne    80108bed <freevm+0x18>
    panic("freevm: no pgdir");
80108be1:	c7 04 24 8f 95 10 80 	movl   $0x8010958f,(%esp)
80108be8:	e8 4d 79 ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108bed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108bf4:	00 
80108bf5:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108bfc:	80 
80108bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80108c00:	89 04 24             	mov    %eax,(%esp)
80108c03:	e8 11 ff ff ff       	call   80108b19 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108c08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c0f:	eb 48                	jmp    80108c59 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c1e:	01 d0                	add    %edx,%eax
80108c20:	8b 00                	mov    (%eax),%eax
80108c22:	83 e0 01             	and    $0x1,%eax
80108c25:	85 c0                	test   %eax,%eax
80108c27:	74 2c                	je     80108c55 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c2c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c33:	8b 45 08             	mov    0x8(%ebp),%eax
80108c36:	01 d0                	add    %edx,%eax
80108c38:	8b 00                	mov    (%eax),%eax
80108c3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c3f:	89 04 24             	mov    %eax,(%esp)
80108c42:	e8 6d f4 ff ff       	call   801080b4 <p2v>
80108c47:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c4d:	89 04 24             	mov    %eax,(%esp)
80108c50:	e8 f0 a5 ff ff       	call   80103245 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108c55:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c59:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108c60:	76 af                	jbe    80108c11 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108c62:	8b 45 08             	mov    0x8(%ebp),%eax
80108c65:	89 04 24             	mov    %eax,(%esp)
80108c68:	e8 d8 a5 ff ff       	call   80103245 <kfree>
}
80108c6d:	c9                   	leave  
80108c6e:	c3                   	ret    

80108c6f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108c6f:	55                   	push   %ebp
80108c70:	89 e5                	mov    %esp,%ebp
80108c72:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108c75:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108c7c:	00 
80108c7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c80:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c84:	8b 45 08             	mov    0x8(%ebp),%eax
80108c87:	89 04 24             	mov    %eax,(%esp)
80108c8a:	e8 a8 f8 ff ff       	call   80108537 <walkpgdir>
80108c8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108c92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108c96:	75 0c                	jne    80108ca4 <clearpteu+0x35>
    panic("clearpteu");
80108c98:	c7 04 24 a0 95 10 80 	movl   $0x801095a0,(%esp)
80108c9f:	e8 96 78 ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
80108ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca7:	8b 00                	mov    (%eax),%eax
80108ca9:	83 e0 fb             	and    $0xfffffffb,%eax
80108cac:	89 c2                	mov    %eax,%edx
80108cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb1:	89 10                	mov    %edx,(%eax)
}
80108cb3:	c9                   	leave  
80108cb4:	c3                   	ret    

80108cb5 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108cb5:	55                   	push   %ebp
80108cb6:	89 e5                	mov    %esp,%ebp
80108cb8:	53                   	push   %ebx
80108cb9:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108cbc:	e8 b0 f9 ff ff       	call   80108671 <setupkvm>
80108cc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108cc4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108cc8:	75 0a                	jne    80108cd4 <copyuvm+0x1f>
    return 0;
80108cca:	b8 00 00 00 00       	mov    $0x0,%eax
80108ccf:	e9 fd 00 00 00       	jmp    80108dd1 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108cd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108cdb:	e9 d0 00 00 00       	jmp    80108db0 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108cea:	00 
80108ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108cef:	8b 45 08             	mov    0x8(%ebp),%eax
80108cf2:	89 04 24             	mov    %eax,(%esp)
80108cf5:	e8 3d f8 ff ff       	call   80108537 <walkpgdir>
80108cfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108cfd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d01:	75 0c                	jne    80108d0f <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108d03:	c7 04 24 aa 95 10 80 	movl   $0x801095aa,(%esp)
80108d0a:	e8 2b 78 ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
80108d0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d12:	8b 00                	mov    (%eax),%eax
80108d14:	83 e0 01             	and    $0x1,%eax
80108d17:	85 c0                	test   %eax,%eax
80108d19:	75 0c                	jne    80108d27 <copyuvm+0x72>
      panic("copyuvm: page not present");
80108d1b:	c7 04 24 c4 95 10 80 	movl   $0x801095c4,(%esp)
80108d22:	e8 13 78 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108d27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d2a:	8b 00                	mov    (%eax),%eax
80108d2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d31:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108d34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d37:	8b 00                	mov    (%eax),%eax
80108d39:	25 ff 0f 00 00       	and    $0xfff,%eax
80108d3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108d41:	e8 98 a5 ff ff       	call   801032de <kalloc>
80108d46:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108d49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108d4d:	75 02                	jne    80108d51 <copyuvm+0x9c>
      goto bad;
80108d4f:	eb 70                	jmp    80108dc1 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108d51:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d54:	89 04 24             	mov    %eax,(%esp)
80108d57:	e8 58 f3 ff ff       	call   801080b4 <p2v>
80108d5c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108d63:	00 
80108d64:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d68:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d6b:	89 04 24             	mov    %eax,(%esp)
80108d6e:	e8 8a cd ff ff       	call   80105afd <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108d73:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108d76:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d79:	89 04 24             	mov    %eax,(%esp)
80108d7c:	e8 26 f3 ff ff       	call   801080a7 <v2p>
80108d81:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d84:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108d88:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108d8c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108d93:	00 
80108d94:	89 54 24 04          	mov    %edx,0x4(%esp)
80108d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d9b:	89 04 24             	mov    %eax,(%esp)
80108d9e:	e8 36 f8 ff ff       	call   801085d9 <mappages>
80108da3:	85 c0                	test   %eax,%eax
80108da5:	79 02                	jns    80108da9 <copyuvm+0xf4>
      goto bad;
80108da7:	eb 18                	jmp    80108dc1 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108da9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108db6:	0f 82 24 ff ff ff    	jb     80108ce0 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108dbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dbf:	eb 10                	jmp    80108dd1 <copyuvm+0x11c>

bad:
  freevm(d);
80108dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dc4:	89 04 24             	mov    %eax,(%esp)
80108dc7:	e8 09 fe ff ff       	call   80108bd5 <freevm>
  return 0;
80108dcc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108dd1:	83 c4 44             	add    $0x44,%esp
80108dd4:	5b                   	pop    %ebx
80108dd5:	5d                   	pop    %ebp
80108dd6:	c3                   	ret    

80108dd7 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108dd7:	55                   	push   %ebp
80108dd8:	89 e5                	mov    %esp,%ebp
80108dda:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108ddd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108de4:	00 
80108de5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108de8:	89 44 24 04          	mov    %eax,0x4(%esp)
80108dec:	8b 45 08             	mov    0x8(%ebp),%eax
80108def:	89 04 24             	mov    %eax,(%esp)
80108df2:	e8 40 f7 ff ff       	call   80108537 <walkpgdir>
80108df7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dfd:	8b 00                	mov    (%eax),%eax
80108dff:	83 e0 01             	and    $0x1,%eax
80108e02:	85 c0                	test   %eax,%eax
80108e04:	75 07                	jne    80108e0d <uva2ka+0x36>
    return 0;
80108e06:	b8 00 00 00 00       	mov    $0x0,%eax
80108e0b:	eb 25                	jmp    80108e32 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e10:	8b 00                	mov    (%eax),%eax
80108e12:	83 e0 04             	and    $0x4,%eax
80108e15:	85 c0                	test   %eax,%eax
80108e17:	75 07                	jne    80108e20 <uva2ka+0x49>
    return 0;
80108e19:	b8 00 00 00 00       	mov    $0x0,%eax
80108e1e:	eb 12                	jmp    80108e32 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e23:	8b 00                	mov    (%eax),%eax
80108e25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e2a:	89 04 24             	mov    %eax,(%esp)
80108e2d:	e8 82 f2 ff ff       	call   801080b4 <p2v>
}
80108e32:	c9                   	leave  
80108e33:	c3                   	ret    

80108e34 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108e34:	55                   	push   %ebp
80108e35:	89 e5                	mov    %esp,%ebp
80108e37:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108e3a:	8b 45 10             	mov    0x10(%ebp),%eax
80108e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108e40:	e9 87 00 00 00       	jmp    80108ecc <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108e45:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108e50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e53:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e57:	8b 45 08             	mov    0x8(%ebp),%eax
80108e5a:	89 04 24             	mov    %eax,(%esp)
80108e5d:	e8 75 ff ff ff       	call   80108dd7 <uva2ka>
80108e62:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108e65:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108e69:	75 07                	jne    80108e72 <copyout+0x3e>
      return -1;
80108e6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e70:	eb 69                	jmp    80108edb <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e75:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108e78:	29 c2                	sub    %eax,%edx
80108e7a:	89 d0                	mov    %edx,%eax
80108e7c:	05 00 10 00 00       	add    $0x1000,%eax
80108e81:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e87:	3b 45 14             	cmp    0x14(%ebp),%eax
80108e8a:	76 06                	jbe    80108e92 <copyout+0x5e>
      n = len;
80108e8c:	8b 45 14             	mov    0x14(%ebp),%eax
80108e8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108e92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e95:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e98:	29 c2                	sub    %eax,%edx
80108e9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e9d:	01 c2                	add    %eax,%edx
80108e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ea2:	89 44 24 08          	mov    %eax,0x8(%esp)
80108ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ead:	89 14 24             	mov    %edx,(%esp)
80108eb0:	e8 48 cc ff ff       	call   80105afd <memmove>
    len -= n;
80108eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb8:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ebe:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108ec1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ec4:	05 00 10 00 00       	add    $0x1000,%eax
80108ec9:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108ecc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108ed0:	0f 85 6f ff ff ff    	jne    80108e45 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108ed6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108edb:	c9                   	leave  
80108edc:	c3                   	ret    
