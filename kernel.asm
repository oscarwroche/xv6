
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

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
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
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
80100028:	bc 90 bf 10 80       	mov    $0x8010bf90,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 f8 2a 10 80       	mov    $0x80102af8,%eax
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
80100037:	53                   	push   %ebx
80100038:	83 ec 0c             	sub    $0xc,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003b:	68 a0 67 10 80       	push   $0x801067a0
80100040:	68 a0 bf 10 80       	push   $0x8010bfa0
80100045:	e8 c2 3e 00 00       	call   80103f0c <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004a:	c7 05 ec 06 11 80 9c 	movl   $0x8011069c,0x801106ec
80100051:	06 11 80 
  bcache.head.next = &bcache.head;
80100054:	c7 05 f0 06 11 80 9c 	movl   $0x8011069c,0x801106f0
8010005b:	06 11 80 
8010005e:	83 c4 10             	add    $0x10,%esp
80100061:	b8 9c 06 11 80       	mov    $0x8011069c,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100066:	bb d4 bf 10 80       	mov    $0x8010bfd4,%ebx
8010006b:	eb 05                	jmp    80100072 <binit+0x3e>
8010006d:	8d 76 00             	lea    0x0(%esi),%esi
80100070:	89 d3                	mov    %edx,%ebx
    b->next = bcache.head.next;
80100072:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100075:	c7 43 50 9c 06 11 80 	movl   $0x8011069c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
8010007c:	83 ec 08             	sub    $0x8,%esp
8010007f:	68 a7 67 10 80       	push   $0x801067a7
80100084:	8d 43 0c             	lea    0xc(%ebx),%eax
80100087:	50                   	push   %eax
80100088:	e8 6f 3d 00 00       	call   80103dfc <initsleeplock>
    bcache.head.next->prev = b;
8010008d:	a1 f0 06 11 80       	mov    0x801106f0,%eax
80100092:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100095:	89 1d f0 06 11 80    	mov    %ebx,0x801106f0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009b:	8d 93 5c 02 00 00    	lea    0x25c(%ebx),%edx
801000a1:	89 d8                	mov    %ebx,%eax
801000a3:	83 c4 10             	add    $0x10,%esp
801000a6:	81 fb 40 04 11 80    	cmp    $0x80110440,%ebx
801000ac:	75 c2                	jne    80100070 <binit+0x3c>
  }
}
801000ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    
801000b3:	90                   	nop

801000b4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000b4:	55                   	push   %ebp
801000b5:	89 e5                	mov    %esp,%ebp
801000b7:	57                   	push   %edi
801000b8:	56                   	push   %esi
801000b9:	53                   	push   %ebx
801000ba:	83 ec 18             	sub    $0x18,%esp
801000bd:	8b 7d 08             	mov    0x8(%ebp),%edi
801000c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&bcache.lock);
801000c3:	68 a0 bf 10 80       	push   $0x8010bfa0
801000c8:	e8 7f 3f 00 00       	call   8010404c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000cd:	8b 1d f0 06 11 80    	mov    0x801106f0,%ebx
801000d3:	83 c4 10             	add    $0x10,%esp
801000d6:	81 fb 9c 06 11 80    	cmp    $0x8011069c,%ebx
801000dc:	75 0d                	jne    801000eb <bread+0x37>
801000de:	eb 1c                	jmp    801000fc <bread+0x48>
801000e0:	8b 5b 54             	mov    0x54(%ebx),%ebx
801000e3:	81 fb 9c 06 11 80    	cmp    $0x8011069c,%ebx
801000e9:	74 11                	je     801000fc <bread+0x48>
    if(b->dev == dev && b->blockno == blockno){
801000eb:	3b 7b 04             	cmp    0x4(%ebx),%edi
801000ee:	75 f0                	jne    801000e0 <bread+0x2c>
801000f0:	3b 73 08             	cmp    0x8(%ebx),%esi
801000f3:	75 eb                	jne    801000e0 <bread+0x2c>
      b->refcnt++;
801000f5:	ff 43 4c             	incl   0x4c(%ebx)
      release(&bcache.lock);
801000f8:	eb 3c                	jmp    80100136 <bread+0x82>
801000fa:	66 90                	xchg   %ax,%ax
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801000fc:	8b 1d ec 06 11 80    	mov    0x801106ec,%ebx
80100102:	81 fb 9c 06 11 80    	cmp    $0x8011069c,%ebx
80100108:	75 0d                	jne    80100117 <bread+0x63>
8010010a:	eb 6c                	jmp    80100178 <bread+0xc4>
8010010c:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010010f:	81 fb 9c 06 11 80    	cmp    $0x8011069c,%ebx
80100115:	74 61                	je     80100178 <bread+0xc4>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100117:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010011a:	85 c0                	test   %eax,%eax
8010011c:	75 ee                	jne    8010010c <bread+0x58>
8010011e:	f6 03 04             	testb  $0x4,(%ebx)
80100121:	75 e9                	jne    8010010c <bread+0x58>
      b->dev = dev;
80100123:	89 7b 04             	mov    %edi,0x4(%ebx)
      b->blockno = blockno;
80100126:	89 73 08             	mov    %esi,0x8(%ebx)
      b->flags = 0;
80100129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
8010012f:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100136:	83 ec 0c             	sub    $0xc,%esp
80100139:	68 a0 bf 10 80       	push   $0x8010bfa0
8010013e:	e8 a1 3f 00 00       	call   801040e4 <release>
      acquiresleep(&b->lock);
80100143:	8d 43 0c             	lea    0xc(%ebx),%eax
80100146:	89 04 24             	mov    %eax,(%esp)
80100149:	e8 e2 3c 00 00       	call   80103e30 <acquiresleep>
      return b;
8010014e:	83 c4 10             	add    $0x10,%esp
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
80100151:	f6 03 02             	testb  $0x2,(%ebx)
80100154:	74 0a                	je     80100160 <bread+0xac>
    iderw(b);
  }
  return b;
}
80100156:	89 d8                	mov    %ebx,%eax
80100158:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010015b:	5b                   	pop    %ebx
8010015c:	5e                   	pop    %esi
8010015d:	5f                   	pop    %edi
8010015e:	5d                   	pop    %ebp
8010015f:	c3                   	ret    
    iderw(b);
80100160:	83 ec 0c             	sub    $0xc,%esp
80100163:	53                   	push   %ebx
80100164:	e8 83 1d 00 00       	call   80101eec <iderw>
80100169:	83 c4 10             	add    $0x10,%esp
}
8010016c:	89 d8                	mov    %ebx,%eax
8010016e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100171:	5b                   	pop    %ebx
80100172:	5e                   	pop    %esi
80100173:	5f                   	pop    %edi
80100174:	5d                   	pop    %ebp
80100175:	c3                   	ret    
80100176:	66 90                	xchg   %ax,%ax
  panic("bget: no buffers");
80100178:	83 ec 0c             	sub    $0xc,%esp
8010017b:	68 ae 67 10 80       	push   $0x801067ae
80100180:	e8 bb 01 00 00       	call   80100340 <panic>
80100185:	8d 76 00             	lea    0x0(%esi),%esi

80100188 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100188:	55                   	push   %ebp
80100189:	89 e5                	mov    %esp,%ebp
8010018b:	53                   	push   %ebx
8010018c:	83 ec 10             	sub    $0x10,%esp
8010018f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
80100192:	8d 43 0c             	lea    0xc(%ebx),%eax
80100195:	50                   	push   %eax
80100196:	e8 25 3d 00 00       	call   80103ec0 <holdingsleep>
8010019b:	83 c4 10             	add    $0x10,%esp
8010019e:	85 c0                	test   %eax,%eax
801001a0:	74 0f                	je     801001b1 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001a2:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001a5:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001ab:	c9                   	leave  
  iderw(b);
801001ac:	e9 3b 1d 00 00       	jmp    80101eec <iderw>
    panic("bwrite");
801001b1:	83 ec 0c             	sub    $0xc,%esp
801001b4:	68 bf 67 10 80       	push   $0x801067bf
801001b9:	e8 82 01 00 00       	call   80100340 <panic>
801001be:	66 90                	xchg   %ax,%ax

801001c0 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001c0:	55                   	push   %ebp
801001c1:	89 e5                	mov    %esp,%ebp
801001c3:	56                   	push   %esi
801001c4:	53                   	push   %ebx
801001c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001c8:	8d 73 0c             	lea    0xc(%ebx),%esi
801001cb:	83 ec 0c             	sub    $0xc,%esp
801001ce:	56                   	push   %esi
801001cf:	e8 ec 3c 00 00       	call   80103ec0 <holdingsleep>
801001d4:	83 c4 10             	add    $0x10,%esp
801001d7:	85 c0                	test   %eax,%eax
801001d9:	74 64                	je     8010023f <brelse+0x7f>
    panic("brelse");

  releasesleep(&b->lock);
801001db:	83 ec 0c             	sub    $0xc,%esp
801001de:	56                   	push   %esi
801001df:	e8 a0 3c 00 00       	call   80103e84 <releasesleep>

  acquire(&bcache.lock);
801001e4:	c7 04 24 a0 bf 10 80 	movl   $0x8010bfa0,(%esp)
801001eb:	e8 5c 3e 00 00       	call   8010404c <acquire>
  b->refcnt--;
801001f0:	8b 43 4c             	mov    0x4c(%ebx),%eax
801001f3:	48                   	dec    %eax
801001f4:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
801001f7:	83 c4 10             	add    $0x10,%esp
801001fa:	85 c0                	test   %eax,%eax
801001fc:	75 2f                	jne    8010022d <brelse+0x6d>
    // no one is waiting for it.
    b->next->prev = b->prev;
801001fe:	8b 43 54             	mov    0x54(%ebx),%eax
80100201:	8b 53 50             	mov    0x50(%ebx),%edx
80100204:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100207:	8b 43 50             	mov    0x50(%ebx),%eax
8010020a:	8b 53 54             	mov    0x54(%ebx),%edx
8010020d:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100210:	a1 f0 06 11 80       	mov    0x801106f0,%eax
80100215:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100218:	c7 43 50 9c 06 11 80 	movl   $0x8011069c,0x50(%ebx)
    bcache.head.next->prev = b;
8010021f:	a1 f0 06 11 80       	mov    0x801106f0,%eax
80100224:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100227:	89 1d f0 06 11 80    	mov    %ebx,0x801106f0
  }
  
  release(&bcache.lock);
8010022d:	c7 45 08 a0 bf 10 80 	movl   $0x8010bfa0,0x8(%ebp)
}
80100234:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100237:	5b                   	pop    %ebx
80100238:	5e                   	pop    %esi
80100239:	5d                   	pop    %ebp
  release(&bcache.lock);
8010023a:	e9 a5 3e 00 00       	jmp    801040e4 <release>
    panic("brelse");
8010023f:	83 ec 0c             	sub    $0xc,%esp
80100242:	68 c6 67 10 80       	push   $0x801067c6
80100247:	e8 f4 00 00 00       	call   80100340 <panic>

8010024c <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
8010024c:	55                   	push   %ebp
8010024d:	89 e5                	mov    %esp,%ebp
8010024f:	57                   	push   %edi
80100250:	56                   	push   %esi
80100251:	53                   	push   %ebx
80100252:	83 ec 18             	sub    $0x18,%esp
80100255:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
80100258:	ff 75 08             	pushl  0x8(%ebp)
8010025b:	e8 c4 13 00 00       	call   80101624 <iunlock>
  target = n;
80100260:	89 de                	mov    %ebx,%esi
  acquire(&cons.lock);
80100262:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100269:	e8 de 3d 00 00       	call   8010404c <acquire>
  while(n > 0){
8010026e:	83 c4 10             	add    $0x10,%esp
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
80100271:	8b 7d 0c             	mov    0xc(%ebp),%edi
80100274:	01 df                	add    %ebx,%edi
  while(n > 0){
80100276:	85 db                	test   %ebx,%ebx
80100278:	0f 8e 91 00 00 00    	jle    8010030f <consoleread+0xc3>
    while(input.r == input.w){
8010027e:	a1 80 09 11 80       	mov    0x80110980,%eax
80100283:	3b 05 84 09 11 80    	cmp    0x80110984,%eax
80100289:	74 27                	je     801002b2 <consoleread+0x66>
8010028b:	eb 57                	jmp    801002e4 <consoleread+0x98>
8010028d:	8d 76 00             	lea    0x0(%esi),%esi
      sleep(&input.r, &cons.lock);
80100290:	83 ec 08             	sub    $0x8,%esp
80100293:	68 20 a5 10 80       	push   $0x8010a520
80100298:	68 80 09 11 80       	push   $0x80110980
8010029d:	e8 4e 36 00 00       	call   801038f0 <sleep>
    while(input.r == input.w){
801002a2:	a1 80 09 11 80       	mov    0x80110980,%eax
801002a7:	83 c4 10             	add    $0x10,%esp
801002aa:	3b 05 84 09 11 80    	cmp    0x80110984,%eax
801002b0:	75 32                	jne    801002e4 <consoleread+0x98>
      if(myproc()->killed){
801002b2:	e8 a9 30 00 00       	call   80103360 <myproc>
801002b7:	8b 48 24             	mov    0x24(%eax),%ecx
801002ba:	85 c9                	test   %ecx,%ecx
801002bc:	74 d2                	je     80100290 <consoleread+0x44>
        release(&cons.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 20 a5 10 80       	push   $0x8010a520
801002c6:	e8 19 3e 00 00       	call   801040e4 <release>
        ilock(ip);
801002cb:	5a                   	pop    %edx
801002cc:	ff 75 08             	pushl  0x8(%ebp)
801002cf:	e8 88 12 00 00       	call   8010155c <ilock>
        return -1;
801002d4:	83 c4 10             	add    $0x10,%esp
801002d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002df:	5b                   	pop    %ebx
801002e0:	5e                   	pop    %esi
801002e1:	5f                   	pop    %edi
801002e2:	5d                   	pop    %ebp
801002e3:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002e4:	8d 50 01             	lea    0x1(%eax),%edx
801002e7:	89 15 80 09 11 80    	mov    %edx,0x80110980
801002ed:	89 c2                	mov    %eax,%edx
801002ef:	83 e2 7f             	and    $0x7f,%edx
801002f2:	0f be 8a 00 09 11 80 	movsbl -0x7feef700(%edx),%ecx
    if(c == C('D')){  // EOF
801002f9:	80 f9 04             	cmp    $0x4,%cl
801002fc:	74 36                	je     80100334 <consoleread+0xe8>
    *dst++ = c;
801002fe:	89 d8                	mov    %ebx,%eax
80100300:	f7 d8                	neg    %eax
80100302:	88 0c 07             	mov    %cl,(%edi,%eax,1)
    --n;
80100305:	4b                   	dec    %ebx
    if(c == '\n')
80100306:	83 f9 0a             	cmp    $0xa,%ecx
80100309:	0f 85 67 ff ff ff    	jne    80100276 <consoleread+0x2a>
  release(&cons.lock);
8010030f:	83 ec 0c             	sub    $0xc,%esp
80100312:	68 20 a5 10 80       	push   $0x8010a520
80100317:	e8 c8 3d 00 00       	call   801040e4 <release>
  ilock(ip);
8010031c:	58                   	pop    %eax
8010031d:	ff 75 08             	pushl  0x8(%ebp)
80100320:	e8 37 12 00 00       	call   8010155c <ilock>
  return target - n;
80100325:	89 f0                	mov    %esi,%eax
80100327:	29 d8                	sub    %ebx,%eax
80100329:	83 c4 10             	add    $0x10,%esp
}
8010032c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010032f:	5b                   	pop    %ebx
80100330:	5e                   	pop    %esi
80100331:	5f                   	pop    %edi
80100332:	5d                   	pop    %ebp
80100333:	c3                   	ret    
      if(n < target){
80100334:	39 f3                	cmp    %esi,%ebx
80100336:	73 d7                	jae    8010030f <consoleread+0xc3>
        input.r--;
80100338:	a3 80 09 11 80       	mov    %eax,0x80110980
8010033d:	eb d0                	jmp    8010030f <consoleread+0xc3>
8010033f:	90                   	nop

80100340 <panic>:
{
80100340:	55                   	push   %ebp
80100341:	89 e5                	mov    %esp,%ebp
80100343:	56                   	push   %esi
80100344:	53                   	push   %ebx
80100345:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100348:	fa                   	cli    
  cons.locking = 0;
80100349:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
80100350:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
80100353:	e8 04 21 00 00       	call   8010245c <lapicid>
80100358:	83 ec 08             	sub    $0x8,%esp
8010035b:	50                   	push   %eax
8010035c:	68 cd 67 10 80       	push   $0x801067cd
80100361:	e8 ba 02 00 00       	call   80100620 <cprintf>
  cprintf(s);
80100366:	58                   	pop    %eax
80100367:	ff 75 08             	pushl  0x8(%ebp)
8010036a:	e8 b1 02 00 00       	call   80100620 <cprintf>
  cprintf("\n");
8010036f:	c7 04 24 1b 71 10 80 	movl   $0x8010711b,(%esp)
80100376:	e8 a5 02 00 00       	call   80100620 <cprintf>
  getcallerpcs(&s, pcs);
8010037b:	5a                   	pop    %edx
8010037c:	59                   	pop    %ecx
8010037d:	8d 5d d0             	lea    -0x30(%ebp),%ebx
80100380:	53                   	push   %ebx
80100381:	8d 45 08             	lea    0x8(%ebp),%eax
80100384:	50                   	push   %eax
80100385:	e8 9e 3b 00 00       	call   80103f28 <getcallerpcs>
  for(i=0; i<10; i++)
8010038a:	8d 75 f8             	lea    -0x8(%ebp),%esi
8010038d:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
80100390:	83 ec 08             	sub    $0x8,%esp
80100393:	ff 33                	pushl  (%ebx)
80100395:	68 e1 67 10 80       	push   $0x801067e1
8010039a:	e8 81 02 00 00       	call   80100620 <cprintf>
  for(i=0; i<10; i++)
8010039f:	83 c3 04             	add    $0x4,%ebx
801003a2:	83 c4 10             	add    $0x10,%esp
801003a5:	39 f3                	cmp    %esi,%ebx
801003a7:	75 e7                	jne    80100390 <panic+0x50>
  panicked = 1; // freeze other CPU
801003a9:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
801003b0:	00 00 00 
  for(;;)
801003b3:	eb fe                	jmp    801003b3 <panic+0x73>
801003b5:	8d 76 00             	lea    0x0(%esi),%esi

801003b8 <consputc.part.0>:
consputc(int c)
801003b8:	55                   	push   %ebp
801003b9:	89 e5                	mov    %esp,%ebp
801003bb:	57                   	push   %edi
801003bc:	56                   	push   %esi
801003bd:	53                   	push   %ebx
801003be:	83 ec 1c             	sub    $0x1c,%esp
801003c1:	89 c6                	mov    %eax,%esi
  if(c == BACKSPACE){
801003c3:	3d 00 01 00 00       	cmp    $0x100,%eax
801003c8:	0f 84 ce 00 00 00    	je     8010049c <consputc.part.0+0xe4>
    uartputc(c);
801003ce:	83 ec 0c             	sub    $0xc,%esp
801003d1:	50                   	push   %eax
801003d2:	e8 bd 50 00 00       	call   80105494 <uartputc>
801003d7:	83 c4 10             	add    $0x10,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003da:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003df:	b0 0e                	mov    $0xe,%al
801003e1:	89 ca                	mov    %ecx,%edx
801003e3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003e4:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003e9:	89 da                	mov    %ebx,%edx
801003eb:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003ec:	0f b6 f8             	movzbl %al,%edi
801003ef:	c1 e7 08             	shl    $0x8,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003f2:	b0 0f                	mov    $0xf,%al
801003f4:	89 ca                	mov    %ecx,%edx
801003f6:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f7:	89 da                	mov    %ebx,%edx
801003f9:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003fa:	0f b6 c8             	movzbl %al,%ecx
801003fd:	09 f9                	or     %edi,%ecx
  if(c == '\n')
801003ff:	83 fe 0a             	cmp    $0xa,%esi
80100402:	0f 84 84 00 00 00    	je     8010048c <consputc.part.0+0xd4>
  else if(c == BACKSPACE){
80100408:	81 fe 00 01 00 00    	cmp    $0x100,%esi
8010040e:	74 6c                	je     8010047c <consputc.part.0+0xc4>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100410:	8d 59 01             	lea    0x1(%ecx),%ebx
80100413:	89 f0                	mov    %esi,%eax
80100415:	0f b6 f0             	movzbl %al,%esi
80100418:	81 ce 00 07 00 00    	or     $0x700,%esi
8010041e:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100425:	80 
  if(pos < 0 || pos > 25*80)
80100426:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
8010042c:	0f 8f ee 00 00 00    	jg     80100520 <consputc.part.0+0x168>
  if((pos/80) >= 24){  // Scroll up.
80100432:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100438:	0f 8f 8a 00 00 00    	jg     801004c8 <consputc.part.0+0x110>
8010043e:	0f b6 c7             	movzbl %bh,%eax
80100441:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100444:	89 de                	mov    %ebx,%esi
80100446:	01 db                	add    %ebx,%ebx
80100448:	8d bb 00 80 0b 80    	lea    -0x7ff48000(%ebx),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010044e:	bb d4 03 00 00       	mov    $0x3d4,%ebx
80100453:	b0 0e                	mov    $0xe,%al
80100455:	89 da                	mov    %ebx,%edx
80100457:	ee                   	out    %al,(%dx)
80100458:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
8010045d:	8a 45 e4             	mov    -0x1c(%ebp),%al
80100460:	89 ca                	mov    %ecx,%edx
80100462:	ee                   	out    %al,(%dx)
80100463:	b0 0f                	mov    $0xf,%al
80100465:	89 da                	mov    %ebx,%edx
80100467:	ee                   	out    %al,(%dx)
80100468:	89 f0                	mov    %esi,%eax
8010046a:	89 ca                	mov    %ecx,%edx
8010046c:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
8010046d:	66 c7 07 20 07       	movw   $0x720,(%edi)
}
80100472:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100475:	5b                   	pop    %ebx
80100476:	5e                   	pop    %esi
80100477:	5f                   	pop    %edi
80100478:	5d                   	pop    %ebp
80100479:	c3                   	ret    
8010047a:	66 90                	xchg   %ax,%ax
    if(pos > 0) --pos;
8010047c:	85 c9                	test   %ecx,%ecx
8010047e:	0f 84 8c 00 00 00    	je     80100510 <consputc.part.0+0x158>
80100484:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100487:	eb 9d                	jmp    80100426 <consputc.part.0+0x6e>
80100489:	8d 76 00             	lea    0x0(%esi),%esi
    pos += 80 - pos%80;
8010048c:	bb 50 00 00 00       	mov    $0x50,%ebx
80100491:	89 c8                	mov    %ecx,%eax
80100493:	99                   	cltd   
80100494:	f7 fb                	idiv   %ebx
80100496:	29 d3                	sub    %edx,%ebx
80100498:	01 cb                	add    %ecx,%ebx
8010049a:	eb 8a                	jmp    80100426 <consputc.part.0+0x6e>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010049c:	83 ec 0c             	sub    $0xc,%esp
8010049f:	6a 08                	push   $0x8
801004a1:	e8 ee 4f 00 00       	call   80105494 <uartputc>
801004a6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004ad:	e8 e2 4f 00 00       	call   80105494 <uartputc>
801004b2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801004b9:	e8 d6 4f 00 00       	call   80105494 <uartputc>
801004be:	83 c4 10             	add    $0x10,%esp
801004c1:	e9 14 ff ff ff       	jmp    801003da <consputc.part.0+0x22>
801004c6:	66 90                	xchg   %ax,%ax
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004c8:	50                   	push   %eax
801004c9:	68 60 0e 00 00       	push   $0xe60
801004ce:	68 a0 80 0b 80       	push   $0x800b80a0
801004d3:	68 00 80 0b 80       	push   $0x800b8000
801004d8:	e8 d3 3c 00 00       	call   801041b0 <memmove>
    pos -= 80;
801004dd:	8d 73 b0             	lea    -0x50(%ebx),%esi
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004e0:	8d 84 1b 60 ff ff ff 	lea    -0xa0(%ebx,%ebx,1),%eax
801004e7:	8d b8 00 80 0b 80    	lea    -0x7ff48000(%eax),%edi
801004ed:	83 c4 0c             	add    $0xc,%esp
801004f0:	b8 80 07 00 00       	mov    $0x780,%eax
801004f5:	29 f0                	sub    %esi,%eax
801004f7:	01 c0                	add    %eax,%eax
801004f9:	50                   	push   %eax
801004fa:	6a 00                	push   $0x0
801004fc:	57                   	push   %edi
801004fd:	e8 2a 3c 00 00       	call   8010412c <memset>
80100502:	83 c4 10             	add    $0x10,%esp
80100505:	c6 45 e4 07          	movb   $0x7,-0x1c(%ebp)
80100509:	e9 40 ff ff ff       	jmp    8010044e <consputc.part.0+0x96>
8010050e:	66 90                	xchg   %ax,%ax
80100510:	bf 00 80 0b 80       	mov    $0x800b8000,%edi
80100515:	31 f6                	xor    %esi,%esi
80100517:	c6 45 e4 00          	movb   $0x0,-0x1c(%ebp)
8010051b:	e9 2e ff ff ff       	jmp    8010044e <consputc.part.0+0x96>
    panic("pos under/overflow");
80100520:	83 ec 0c             	sub    $0xc,%esp
80100523:	68 e5 67 10 80       	push   $0x801067e5
80100528:	e8 13 fe ff ff       	call   80100340 <panic>
8010052d:	8d 76 00             	lea    0x0(%esi),%esi

80100530 <printint>:
{
80100530:	55                   	push   %ebp
80100531:	89 e5                	mov    %esp,%ebp
80100533:	57                   	push   %edi
80100534:	56                   	push   %esi
80100535:	53                   	push   %ebx
80100536:	83 ec 2c             	sub    $0x2c,%esp
80100539:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  if(sign && (sign = xx < 0))
8010053c:	85 c9                	test   %ecx,%ecx
8010053e:	74 04                	je     80100544 <printint+0x14>
80100540:	85 c0                	test   %eax,%eax
80100542:	78 5e                	js     801005a2 <printint+0x72>
    x = xx;
80100544:	89 c1                	mov    %eax,%ecx
80100546:	31 db                	xor    %ebx,%ebx
  i = 0;
80100548:	31 ff                	xor    %edi,%edi
    buf[i++] = digits[x % base];
8010054a:	89 c8                	mov    %ecx,%eax
8010054c:	31 d2                	xor    %edx,%edx
8010054e:	f7 75 d4             	divl   -0x2c(%ebp)
80100551:	89 fe                	mov    %edi,%esi
80100553:	8d 7f 01             	lea    0x1(%edi),%edi
80100556:	8a 92 10 68 10 80    	mov    -0x7fef97f0(%edx),%dl
8010055c:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
80100560:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80100563:	89 c1                	mov    %eax,%ecx
80100565:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100568:	39 45 d0             	cmp    %eax,-0x30(%ebp)
8010056b:	73 dd                	jae    8010054a <printint+0x1a>
  if(sign)
8010056d:	85 db                	test   %ebx,%ebx
8010056f:	74 09                	je     8010057a <printint+0x4a>
    buf[i++] = '-';
80100571:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
    buf[i++] = digits[x % base];
80100576:	89 fe                	mov    %edi,%esi
    buf[i++] = '-';
80100578:	b2 2d                	mov    $0x2d,%dl
  while(--i >= 0)
8010057a:	8d 5c 35 d7          	lea    -0x29(%ebp,%esi,1),%ebx
8010057e:	0f be c2             	movsbl %dl,%eax
  if(panicked){
80100581:	8b 15 58 a5 10 80    	mov    0x8010a558,%edx
80100587:	85 d2                	test   %edx,%edx
80100589:	74 05                	je     80100590 <printint+0x60>
  asm volatile("cli");
8010058b:	fa                   	cli    
    for(;;)
8010058c:	eb fe                	jmp    8010058c <printint+0x5c>
8010058e:	66 90                	xchg   %ax,%ax
80100590:	e8 23 fe ff ff       	call   801003b8 <consputc.part.0>
  while(--i >= 0)
80100595:	8d 45 d7             	lea    -0x29(%ebp),%eax
80100598:	39 c3                	cmp    %eax,%ebx
8010059a:	74 0e                	je     801005aa <printint+0x7a>
8010059c:	0f be 03             	movsbl (%ebx),%eax
8010059f:	4b                   	dec    %ebx
801005a0:	eb df                	jmp    80100581 <printint+0x51>
801005a2:	89 cb                	mov    %ecx,%ebx
    x = -xx;
801005a4:	f7 d8                	neg    %eax
801005a6:	89 c1                	mov    %eax,%ecx
801005a8:	eb 9e                	jmp    80100548 <printint+0x18>
}
801005aa:	83 c4 2c             	add    $0x2c,%esp
801005ad:	5b                   	pop    %ebx
801005ae:	5e                   	pop    %esi
801005af:	5f                   	pop    %edi
801005b0:	5d                   	pop    %ebp
801005b1:	c3                   	ret    
801005b2:	66 90                	xchg   %ax,%ax

801005b4 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005b4:	55                   	push   %ebp
801005b5:	89 e5                	mov    %esp,%ebp
801005b7:	57                   	push   %edi
801005b8:	56                   	push   %esi
801005b9:	53                   	push   %ebx
801005ba:	83 ec 18             	sub    $0x18,%esp
801005bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  int i;

  iunlock(ip);
801005c0:	ff 75 08             	pushl  0x8(%ebp)
801005c3:	e8 5c 10 00 00       	call   80101624 <iunlock>
  acquire(&cons.lock);
801005c8:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005cf:	e8 78 3a 00 00       	call   8010404c <acquire>
  for(i = 0; i < n; i++)
801005d4:	83 c4 10             	add    $0x10,%esp
801005d7:	85 ff                	test   %edi,%edi
801005d9:	7e 22                	jle    801005fd <consolewrite+0x49>
801005db:	8b 75 0c             	mov    0xc(%ebp),%esi
801005de:	8d 1c 3e             	lea    (%esi,%edi,1),%ebx
  if(panicked){
801005e1:	8b 15 58 a5 10 80    	mov    0x8010a558,%edx
801005e7:	85 d2                	test   %edx,%edx
801005e9:	74 05                	je     801005f0 <consolewrite+0x3c>
801005eb:	fa                   	cli    
    for(;;)
801005ec:	eb fe                	jmp    801005ec <consolewrite+0x38>
801005ee:	66 90                	xchg   %ax,%ax
    consputc(buf[i] & 0xff);
801005f0:	0f b6 06             	movzbl (%esi),%eax
801005f3:	e8 c0 fd ff ff       	call   801003b8 <consputc.part.0>
  for(i = 0; i < n; i++)
801005f8:	46                   	inc    %esi
801005f9:	39 f3                	cmp    %esi,%ebx
801005fb:	75 e4                	jne    801005e1 <consolewrite+0x2d>
  release(&cons.lock);
801005fd:	83 ec 0c             	sub    $0xc,%esp
80100600:	68 20 a5 10 80       	push   $0x8010a520
80100605:	e8 da 3a 00 00       	call   801040e4 <release>
  ilock(ip);
8010060a:	58                   	pop    %eax
8010060b:	ff 75 08             	pushl  0x8(%ebp)
8010060e:	e8 49 0f 00 00       	call   8010155c <ilock>

  return n;
}
80100613:	89 f8                	mov    %edi,%eax
80100615:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100618:	5b                   	pop    %ebx
80100619:	5e                   	pop    %esi
8010061a:	5f                   	pop    %edi
8010061b:	5d                   	pop    %ebp
8010061c:	c3                   	ret    
8010061d:	8d 76 00             	lea    0x0(%esi),%esi

80100620 <cprintf>:
{
80100620:	55                   	push   %ebp
80100621:	89 e5                	mov    %esp,%ebp
80100623:	57                   	push   %edi
80100624:	56                   	push   %esi
80100625:	53                   	push   %ebx
80100626:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100629:	a1 54 a5 10 80       	mov    0x8010a554,%eax
8010062e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(locking)
80100631:	85 c0                	test   %eax,%eax
80100633:	0f 85 dc 00 00 00    	jne    80100715 <cprintf+0xf5>
  if (fmt == 0)
80100639:	8b 75 08             	mov    0x8(%ebp),%esi
8010063c:	85 f6                	test   %esi,%esi
8010063e:	0f 84 49 01 00 00    	je     8010078d <cprintf+0x16d>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100644:	0f b6 06             	movzbl (%esi),%eax
80100647:	85 c0                	test   %eax,%eax
80100649:	74 35                	je     80100680 <cprintf+0x60>
  argp = (uint*)(void*)(&fmt + 1);
8010064b:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010064e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if(c != '%'){
80100655:	83 f8 25             	cmp    $0x25,%eax
80100658:	74 3a                	je     80100694 <cprintf+0x74>
  if(panicked){
8010065a:	8b 0d 58 a5 10 80    	mov    0x8010a558,%ecx
80100660:	85 c9                	test   %ecx,%ecx
80100662:	74 09                	je     8010066d <cprintf+0x4d>
80100664:	fa                   	cli    
    for(;;)
80100665:	eb fe                	jmp    80100665 <cprintf+0x45>
80100667:	90                   	nop
80100668:	b8 25 00 00 00       	mov    $0x25,%eax
8010066d:	e8 46 fd ff ff       	call   801003b8 <consputc.part.0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100672:	ff 45 e4             	incl   -0x1c(%ebp)
80100675:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100678:	0f b6 04 06          	movzbl (%esi,%eax,1),%eax
8010067c:	85 c0                	test   %eax,%eax
8010067e:	75 d5                	jne    80100655 <cprintf+0x35>
  if(locking)
80100680:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100683:	85 c0                	test   %eax,%eax
80100685:	0f 85 ed 00 00 00    	jne    80100778 <cprintf+0x158>
}
8010068b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010068e:	5b                   	pop    %ebx
8010068f:	5e                   	pop    %esi
80100690:	5f                   	pop    %edi
80100691:	5d                   	pop    %ebp
80100692:	c3                   	ret    
80100693:	90                   	nop
    c = fmt[++i] & 0xff;
80100694:	ff 45 e4             	incl   -0x1c(%ebp)
80100697:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010069a:	0f b6 3c 06          	movzbl (%esi,%eax,1),%edi
    if(c == 0)
8010069e:	85 ff                	test   %edi,%edi
801006a0:	74 de                	je     80100680 <cprintf+0x60>
    switch(c){
801006a2:	83 ff 70             	cmp    $0x70,%edi
801006a5:	74 56                	je     801006fd <cprintf+0xdd>
801006a7:	7f 2a                	jg     801006d3 <cprintf+0xb3>
801006a9:	83 ff 25             	cmp    $0x25,%edi
801006ac:	0f 84 8c 00 00 00    	je     8010073e <cprintf+0x11e>
801006b2:	83 ff 64             	cmp    $0x64,%edi
801006b5:	0f 85 95 00 00 00    	jne    80100750 <cprintf+0x130>
      printint(*argp++, 10, 1);
801006bb:	8d 7b 04             	lea    0x4(%ebx),%edi
801006be:	b9 01 00 00 00       	mov    $0x1,%ecx
801006c3:	ba 0a 00 00 00       	mov    $0xa,%edx
801006c8:	8b 03                	mov    (%ebx),%eax
801006ca:	e8 61 fe ff ff       	call   80100530 <printint>
801006cf:	89 fb                	mov    %edi,%ebx
      break;
801006d1:	eb 9f                	jmp    80100672 <cprintf+0x52>
    switch(c){
801006d3:	83 ff 73             	cmp    $0x73,%edi
801006d6:	75 20                	jne    801006f8 <cprintf+0xd8>
      if((s = (char*)*argp++) == 0)
801006d8:	8d 7b 04             	lea    0x4(%ebx),%edi
801006db:	8b 1b                	mov    (%ebx),%ebx
801006dd:	85 db                	test   %ebx,%ebx
801006df:	75 4f                	jne    80100730 <cprintf+0x110>
        s = "(null)";
801006e1:	bb f8 67 10 80       	mov    $0x801067f8,%ebx
      for(; *s; s++)
801006e6:	b8 28 00 00 00       	mov    $0x28,%eax
  if(panicked){
801006eb:	8b 15 58 a5 10 80    	mov    0x8010a558,%edx
801006f1:	85 d2                	test   %edx,%edx
801006f3:	74 35                	je     8010072a <cprintf+0x10a>
801006f5:	fa                   	cli    
    for(;;)
801006f6:	eb fe                	jmp    801006f6 <cprintf+0xd6>
    switch(c){
801006f8:	83 ff 78             	cmp    $0x78,%edi
801006fb:	75 53                	jne    80100750 <cprintf+0x130>
      printint(*argp++, 16, 0);
801006fd:	8d 7b 04             	lea    0x4(%ebx),%edi
80100700:	31 c9                	xor    %ecx,%ecx
80100702:	ba 10 00 00 00       	mov    $0x10,%edx
80100707:	8b 03                	mov    (%ebx),%eax
80100709:	e8 22 fe ff ff       	call   80100530 <printint>
8010070e:	89 fb                	mov    %edi,%ebx
      break;
80100710:	e9 5d ff ff ff       	jmp    80100672 <cprintf+0x52>
    acquire(&cons.lock);
80100715:	83 ec 0c             	sub    $0xc,%esp
80100718:	68 20 a5 10 80       	push   $0x8010a520
8010071d:	e8 2a 39 00 00       	call   8010404c <acquire>
80100722:	83 c4 10             	add    $0x10,%esp
80100725:	e9 0f ff ff ff       	jmp    80100639 <cprintf+0x19>
8010072a:	e8 89 fc ff ff       	call   801003b8 <consputc.part.0>
      for(; *s; s++)
8010072f:	43                   	inc    %ebx
80100730:	0f be 03             	movsbl (%ebx),%eax
80100733:	84 c0                	test   %al,%al
80100735:	75 b4                	jne    801006eb <cprintf+0xcb>
      if((s = (char*)*argp++) == 0)
80100737:	89 fb                	mov    %edi,%ebx
80100739:	e9 34 ff ff ff       	jmp    80100672 <cprintf+0x52>
  if(panicked){
8010073e:	8b 3d 58 a5 10 80    	mov    0x8010a558,%edi
80100744:	85 ff                	test   %edi,%edi
80100746:	0f 84 1c ff ff ff    	je     80100668 <cprintf+0x48>
8010074c:	fa                   	cli    
    for(;;)
8010074d:	eb fe                	jmp    8010074d <cprintf+0x12d>
8010074f:	90                   	nop
  if(panicked){
80100750:	8b 0d 58 a5 10 80    	mov    0x8010a558,%ecx
80100756:	85 c9                	test   %ecx,%ecx
80100758:	74 06                	je     80100760 <cprintf+0x140>
8010075a:	fa                   	cli    
    for(;;)
8010075b:	eb fe                	jmp    8010075b <cprintf+0x13b>
8010075d:	8d 76 00             	lea    0x0(%esi),%esi
80100760:	b8 25 00 00 00       	mov    $0x25,%eax
80100765:	e8 4e fc ff ff       	call   801003b8 <consputc.part.0>
  if(panicked){
8010076a:	8b 15 58 a5 10 80    	mov    0x8010a558,%edx
80100770:	85 d2                	test   %edx,%edx
80100772:	74 28                	je     8010079c <cprintf+0x17c>
80100774:	fa                   	cli    
    for(;;)
80100775:	eb fe                	jmp    80100775 <cprintf+0x155>
80100777:	90                   	nop
    release(&cons.lock);
80100778:	83 ec 0c             	sub    $0xc,%esp
8010077b:	68 20 a5 10 80       	push   $0x8010a520
80100780:	e8 5f 39 00 00       	call   801040e4 <release>
80100785:	83 c4 10             	add    $0x10,%esp
}
80100788:	e9 fe fe ff ff       	jmp    8010068b <cprintf+0x6b>
    panic("null fmt");
8010078d:	83 ec 0c             	sub    $0xc,%esp
80100790:	68 ff 67 10 80       	push   $0x801067ff
80100795:	e8 a6 fb ff ff       	call   80100340 <panic>
8010079a:	66 90                	xchg   %ax,%ax
8010079c:	89 f8                	mov    %edi,%eax
8010079e:	e8 15 fc ff ff       	call   801003b8 <consputc.part.0>
801007a3:	e9 ca fe ff ff       	jmp    80100672 <cprintf+0x52>

801007a8 <consoleintr>:
{
801007a8:	55                   	push   %ebp
801007a9:	89 e5                	mov    %esp,%ebp
801007ab:	57                   	push   %edi
801007ac:	56                   	push   %esi
801007ad:	53                   	push   %ebx
801007ae:	83 ec 18             	sub    $0x18,%esp
801007b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  acquire(&cons.lock);
801007b4:	68 20 a5 10 80       	push   $0x8010a520
801007b9:	e8 8e 38 00 00       	call   8010404c <acquire>
  while((c = getc()) >= 0){
801007be:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
801007c1:	31 f6                	xor    %esi,%esi
  while((c = getc()) >= 0){
801007c3:	eb 17                	jmp    801007dc <consoleintr+0x34>
    switch(c){
801007c5:	83 fb 08             	cmp    $0x8,%ebx
801007c8:	0f 84 02 01 00 00    	je     801008d0 <consoleintr+0x128>
801007ce:	83 fb 10             	cmp    $0x10,%ebx
801007d1:	0f 85 1d 01 00 00    	jne    801008f4 <consoleintr+0x14c>
801007d7:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
801007dc:	ff d7                	call   *%edi
801007de:	89 c3                	mov    %eax,%ebx
801007e0:	85 c0                	test   %eax,%eax
801007e2:	0f 88 2b 01 00 00    	js     80100913 <consoleintr+0x16b>
    switch(c){
801007e8:	83 fb 15             	cmp    $0x15,%ebx
801007eb:	0f 84 8b 00 00 00    	je     8010087c <consoleintr+0xd4>
801007f1:	7e d2                	jle    801007c5 <consoleintr+0x1d>
801007f3:	83 fb 7f             	cmp    $0x7f,%ebx
801007f6:	0f 84 d4 00 00 00    	je     801008d0 <consoleintr+0x128>
      if(c != 0 && input.e-input.r < INPUT_BUF){
801007fc:	a1 88 09 11 80       	mov    0x80110988,%eax
80100801:	89 c2                	mov    %eax,%edx
80100803:	2b 15 80 09 11 80    	sub    0x80110980,%edx
80100809:	83 fa 7f             	cmp    $0x7f,%edx
8010080c:	77 ce                	ja     801007dc <consoleintr+0x34>
        c = (c == '\r') ? '\n' : c;
8010080e:	8b 15 58 a5 10 80    	mov    0x8010a558,%edx
80100814:	8d 48 01             	lea    0x1(%eax),%ecx
80100817:	83 e0 7f             	and    $0x7f,%eax
        input.buf[input.e++ % INPUT_BUF] = c;
8010081a:	89 0d 88 09 11 80    	mov    %ecx,0x80110988
        c = (c == '\r') ? '\n' : c;
80100820:	83 fb 0d             	cmp    $0xd,%ebx
80100823:	0f 84 06 01 00 00    	je     8010092f <consoleintr+0x187>
        input.buf[input.e++ % INPUT_BUF] = c;
80100829:	88 98 00 09 11 80    	mov    %bl,-0x7feef700(%eax)
  if(panicked){
8010082f:	85 d2                	test   %edx,%edx
80100831:	0f 85 03 01 00 00    	jne    8010093a <consoleintr+0x192>
80100837:	89 d8                	mov    %ebx,%eax
80100839:	e8 7a fb ff ff       	call   801003b8 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010083e:	a1 88 09 11 80       	mov    0x80110988,%eax
80100843:	83 fb 0a             	cmp    $0xa,%ebx
80100846:	74 19                	je     80100861 <consoleintr+0xb9>
80100848:	83 fb 04             	cmp    $0x4,%ebx
8010084b:	74 14                	je     80100861 <consoleintr+0xb9>
8010084d:	8b 0d 80 09 11 80    	mov    0x80110980,%ecx
80100853:	8d 91 80 00 00 00    	lea    0x80(%ecx),%edx
80100859:	39 c2                	cmp    %eax,%edx
8010085b:	0f 85 7b ff ff ff    	jne    801007dc <consoleintr+0x34>
          input.w = input.e;
80100861:	a3 84 09 11 80       	mov    %eax,0x80110984
          wakeup(&input.r);
80100866:	83 ec 0c             	sub    $0xc,%esp
80100869:	68 80 09 11 80       	push   $0x80110980
8010086e:	e8 29 32 00 00       	call   80103a9c <wakeup>
80100873:	83 c4 10             	add    $0x10,%esp
80100876:	e9 61 ff ff ff       	jmp    801007dc <consoleintr+0x34>
8010087b:	90                   	nop
      while(input.e != input.w &&
8010087c:	a1 88 09 11 80       	mov    0x80110988,%eax
80100881:	39 05 84 09 11 80    	cmp    %eax,0x80110984
80100887:	0f 84 4f ff ff ff    	je     801007dc <consoleintr+0x34>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010088d:	48                   	dec    %eax
8010088e:	89 c2                	mov    %eax,%edx
80100890:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100893:	80 ba 00 09 11 80 0a 	cmpb   $0xa,-0x7feef700(%edx)
8010089a:	0f 84 3c ff ff ff    	je     801007dc <consoleintr+0x34>
        input.e--;
801008a0:	a3 88 09 11 80       	mov    %eax,0x80110988
  if(panicked){
801008a5:	8b 15 58 a5 10 80    	mov    0x8010a558,%edx
801008ab:	85 d2                	test   %edx,%edx
801008ad:	74 05                	je     801008b4 <consoleintr+0x10c>
801008af:	fa                   	cli    
    for(;;)
801008b0:	eb fe                	jmp    801008b0 <consoleintr+0x108>
801008b2:	66 90                	xchg   %ax,%ax
801008b4:	b8 00 01 00 00       	mov    $0x100,%eax
801008b9:	e8 fa fa ff ff       	call   801003b8 <consputc.part.0>
      while(input.e != input.w &&
801008be:	a1 88 09 11 80       	mov    0x80110988,%eax
801008c3:	3b 05 84 09 11 80    	cmp    0x80110984,%eax
801008c9:	75 c2                	jne    8010088d <consoleintr+0xe5>
801008cb:	e9 0c ff ff ff       	jmp    801007dc <consoleintr+0x34>
      if(input.e != input.w){
801008d0:	a1 88 09 11 80       	mov    0x80110988,%eax
801008d5:	3b 05 84 09 11 80    	cmp    0x80110984,%eax
801008db:	0f 84 fb fe ff ff    	je     801007dc <consoleintr+0x34>
        input.e--;
801008e1:	48                   	dec    %eax
801008e2:	a3 88 09 11 80       	mov    %eax,0x80110988
  if(panicked){
801008e7:	a1 58 a5 10 80       	mov    0x8010a558,%eax
801008ec:	85 c0                	test   %eax,%eax
801008ee:	74 14                	je     80100904 <consoleintr+0x15c>
801008f0:	fa                   	cli    
    for(;;)
801008f1:	eb fe                	jmp    801008f1 <consoleintr+0x149>
801008f3:	90                   	nop
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008f4:	85 db                	test   %ebx,%ebx
801008f6:	0f 84 e0 fe ff ff    	je     801007dc <consoleintr+0x34>
801008fc:	e9 fb fe ff ff       	jmp    801007fc <consoleintr+0x54>
80100901:	8d 76 00             	lea    0x0(%esi),%esi
80100904:	b8 00 01 00 00       	mov    $0x100,%eax
80100909:	e8 aa fa ff ff       	call   801003b8 <consputc.part.0>
8010090e:	e9 c9 fe ff ff       	jmp    801007dc <consoleintr+0x34>
  release(&cons.lock);
80100913:	83 ec 0c             	sub    $0xc,%esp
80100916:	68 20 a5 10 80       	push   $0x8010a520
8010091b:	e8 c4 37 00 00       	call   801040e4 <release>
  if(doprocdump) {
80100920:	83 c4 10             	add    $0x10,%esp
80100923:	85 f6                	test   %esi,%esi
80100925:	75 19                	jne    80100940 <consoleintr+0x198>
}
80100927:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010092a:	5b                   	pop    %ebx
8010092b:	5e                   	pop    %esi
8010092c:	5f                   	pop    %edi
8010092d:	5d                   	pop    %ebp
8010092e:	c3                   	ret    
        input.buf[input.e++ % INPUT_BUF] = c;
8010092f:	c6 80 00 09 11 80 0a 	movb   $0xa,-0x7feef700(%eax)
  if(panicked){
80100936:	85 d2                	test   %edx,%edx
80100938:	74 12                	je     8010094c <consoleintr+0x1a4>
8010093a:	fa                   	cli    
    for(;;)
8010093b:	eb fe                	jmp    8010093b <consoleintr+0x193>
8010093d:	8d 76 00             	lea    0x0(%esi),%esi
}
80100940:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100943:	5b                   	pop    %ebx
80100944:	5e                   	pop    %esi
80100945:	5f                   	pop    %edi
80100946:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100947:	e9 20 32 00 00       	jmp    80103b6c <procdump>
8010094c:	b8 0a 00 00 00       	mov    $0xa,%eax
80100951:	e8 62 fa ff ff       	call   801003b8 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100956:	a1 88 09 11 80       	mov    0x80110988,%eax
8010095b:	e9 01 ff ff ff       	jmp    80100861 <consoleintr+0xb9>

80100960 <consoleinit>:

void
consoleinit(void)
{
80100960:	55                   	push   %ebp
80100961:	89 e5                	mov    %esp,%ebp
80100963:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100966:	68 08 68 10 80       	push   $0x80106808
8010096b:	68 20 a5 10 80       	push   $0x8010a520
80100970:	e8 97 35 00 00       	call   80103f0c <initlock>

  devsw[CONSOLE].write = consolewrite;
80100975:	c7 05 4c 13 11 80 b4 	movl   $0x801005b4,0x8011134c
8010097c:	05 10 80 
  devsw[CONSOLE].read = consoleread;
8010097f:	c7 05 48 13 11 80 4c 	movl   $0x8010024c,0x80111348
80100986:	02 10 80 
  cons.locking = 1;
80100989:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
80100990:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100993:	58                   	pop    %eax
80100994:	5a                   	pop    %edx
80100995:	6a 00                	push   $0x0
80100997:	6a 01                	push   $0x1
80100999:	e8 d2 16 00 00       	call   80102070 <ioapicenable>
}
8010099e:	83 c4 10             	add    $0x10,%esp
801009a1:	c9                   	leave  
801009a2:	c3                   	ret    
801009a3:	90                   	nop

801009a4 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801009a4:	55                   	push   %ebp
801009a5:	89 e5                	mov    %esp,%ebp
801009a7:	57                   	push   %edi
801009a8:	56                   	push   %esi
801009a9:	53                   	push   %ebx
801009aa:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801009b0:	e8 ab 29 00 00       	call   80103360 <myproc>
801009b5:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
801009bb:	e8 7c 1e 00 00       	call   8010283c <begin_op>

  if((ip = namei(path)) == 0){
801009c0:	83 ec 0c             	sub    $0xc,%esp
801009c3:	ff 75 08             	pushl  0x8(%ebp)
801009c6:	e8 45 13 00 00       	call   80101d10 <namei>
801009cb:	83 c4 10             	add    $0x10,%esp
801009ce:	85 c0                	test   %eax,%eax
801009d0:	0f 84 da 02 00 00    	je     80100cb0 <exec+0x30c>
801009d6:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
801009d8:	83 ec 0c             	sub    $0xc,%esp
801009db:	50                   	push   %eax
801009dc:	e8 7b 0b 00 00       	call   8010155c <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
801009e1:	6a 34                	push   $0x34
801009e3:	6a 00                	push   $0x0
801009e5:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
801009eb:	50                   	push   %eax
801009ec:	53                   	push   %ebx
801009ed:	e8 0e 0e 00 00       	call   80101800 <readi>
801009f2:	83 c4 20             	add    $0x20,%esp
801009f5:	83 f8 34             	cmp    $0x34,%eax
801009f8:	74 1e                	je     80100a18 <exec+0x74>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
801009fa:	83 ec 0c             	sub    $0xc,%esp
801009fd:	53                   	push   %ebx
801009fe:	e8 b1 0d 00 00       	call   801017b4 <iunlockput>
    end_op();
80100a03:	e8 9c 1e 00 00       	call   801028a4 <end_op>
80100a08:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100a0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100a10:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100a13:	5b                   	pop    %ebx
80100a14:	5e                   	pop    %esi
80100a15:	5f                   	pop    %edi
80100a16:	5d                   	pop    %ebp
80100a17:	c3                   	ret    
  if(elf.magic != ELF_MAGIC)
80100a18:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100a1f:	45 4c 46 
80100a22:	75 d6                	jne    801009fa <exec+0x56>
  if((pgdir = setupkvm()) == 0)
80100a24:	e8 1b 5b 00 00       	call   80106544 <setupkvm>
80100a29:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a2f:	85 c0                	test   %eax,%eax
80100a31:	74 c7                	je     801009fa <exec+0x56>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100a33:	8b b5 40 ff ff ff    	mov    -0xc0(%ebp),%esi
  sz = 0;
80100a39:	31 ff                	xor    %edi,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100a3b:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100a42:	00 
80100a43:	0f 84 86 02 00 00    	je     80100ccf <exec+0x32b>
80100a49:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
80100a50:	00 00 00 
80100a53:	e9 84 00 00 00       	jmp    80100adc <exec+0x138>
    if(ph.type != ELF_PROG_LOAD)
80100a58:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100a5f:	75 61                	jne    80100ac2 <exec+0x11e>
    if(ph.memsz < ph.filesz)
80100a61:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100a67:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100a6d:	0f 82 85 00 00 00    	jb     80100af8 <exec+0x154>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100a73:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100a79:	72 7d                	jb     80100af8 <exec+0x154>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100a7b:	51                   	push   %ecx
80100a7c:	50                   	push   %eax
80100a7d:	57                   	push   %edi
80100a7e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100a84:	e8 07 59 00 00       	call   80106390 <allocuvm>
80100a89:	89 c7                	mov    %eax,%edi
80100a8b:	83 c4 10             	add    $0x10,%esp
80100a8e:	85 c0                	test   %eax,%eax
80100a90:	74 66                	je     80100af8 <exec+0x154>
    if(ph.vaddr % PGSIZE != 0)
80100a92:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a98:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a9d:	75 59                	jne    80100af8 <exec+0x154>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100aa8:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100aae:	53                   	push   %ebx
80100aaf:	50                   	push   %eax
80100ab0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100ab6:	e8 19 58 00 00       	call   801062d4 <loaduvm>
80100abb:	83 c4 20             	add    $0x20,%esp
80100abe:	85 c0                	test   %eax,%eax
80100ac0:	78 36                	js     80100af8 <exec+0x154>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ac2:	ff 85 f4 fe ff ff    	incl   -0x10c(%ebp)
80100ac8:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100ace:	83 c6 20             	add    $0x20,%esi
80100ad1:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100ad8:	39 c8                	cmp    %ecx,%eax
80100ada:	7e 34                	jle    80100b10 <exec+0x16c>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100adc:	6a 20                	push   $0x20
80100ade:	56                   	push   %esi
80100adf:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100ae5:	50                   	push   %eax
80100ae6:	53                   	push   %ebx
80100ae7:	e8 14 0d 00 00       	call   80101800 <readi>
80100aec:	83 c4 10             	add    $0x10,%esp
80100aef:	83 f8 20             	cmp    $0x20,%eax
80100af2:	0f 84 60 ff ff ff    	je     80100a58 <exec+0xb4>
    freevm(pgdir);
80100af8:	83 ec 0c             	sub    $0xc,%esp
80100afb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100b01:	e8 ce 59 00 00       	call   801064d4 <freevm>
  if(ip){
80100b06:	83 c4 10             	add    $0x10,%esp
80100b09:	e9 ec fe ff ff       	jmp    801009fa <exec+0x56>
80100b0e:	66 90                	xchg   %ax,%ax
80100b10:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
80100b16:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
80100b1c:	8d b7 00 20 00 00    	lea    0x2000(%edi),%esi
  iunlockput(ip);
80100b22:	83 ec 0c             	sub    $0xc,%esp
80100b25:	53                   	push   %ebx
80100b26:	e8 89 0c 00 00       	call   801017b4 <iunlockput>
  end_op();
80100b2b:	e8 74 1d 00 00       	call   801028a4 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100b30:	83 c4 0c             	add    $0xc,%esp
80100b33:	56                   	push   %esi
80100b34:	57                   	push   %edi
80100b35:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
80100b3b:	56                   	push   %esi
80100b3c:	e8 4f 58 00 00       	call   80106390 <allocuvm>
80100b41:	89 c7                	mov    %eax,%edi
80100b43:	83 c4 10             	add    $0x10,%esp
80100b46:	85 c0                	test   %eax,%eax
80100b48:	0f 84 8a 00 00 00    	je     80100bd8 <exec+0x234>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100b4e:	83 ec 08             	sub    $0x8,%esp
80100b51:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100b57:	50                   	push   %eax
80100b58:	56                   	push   %esi
80100b59:	e8 76 5a 00 00       	call   801065d4 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b61:	8b 00                	mov    (%eax),%eax
80100b63:	83 c4 10             	add    $0x10,%esp
80100b66:	89 fb                	mov    %edi,%ebx
80100b68:	31 f6                	xor    %esi,%esi
80100b6a:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
80100b70:	85 c0                	test   %eax,%eax
80100b72:	0f 84 81 00 00 00    	je     80100bf9 <exec+0x255>
80100b78:	89 bd f4 fe ff ff    	mov    %edi,-0x10c(%ebp)
80100b7e:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100b84:	eb 1f                	jmp    80100ba5 <exec+0x201>
80100b86:	66 90                	xchg   %ax,%ax
    ustack[3+argc] = sp;
80100b88:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
80100b8e:	89 9c b5 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%esi,4)
  for(argc = 0; argv[argc]; argc++) {
80100b95:	46                   	inc    %esi
80100b96:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b99:	8b 04 b0             	mov    (%eax,%esi,4),%eax
80100b9c:	85 c0                	test   %eax,%eax
80100b9e:	74 53                	je     80100bf3 <exec+0x24f>
    if(argc >= MAXARG)
80100ba0:	83 fe 20             	cmp    $0x20,%esi
80100ba3:	74 33                	je     80100bd8 <exec+0x234>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	50                   	push   %eax
80100ba9:	e8 06 37 00 00       	call   801042b4 <strlen>
80100bae:	f7 d0                	not    %eax
80100bb0:	01 c3                	add    %eax,%ebx
80100bb2:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100bb5:	5a                   	pop    %edx
80100bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100bb9:	ff 34 b0             	pushl  (%eax,%esi,4)
80100bbc:	e8 f3 36 00 00       	call   801042b4 <strlen>
80100bc1:	40                   	inc    %eax
80100bc2:	50                   	push   %eax
80100bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100bc6:	ff 34 b0             	pushl  (%eax,%esi,4)
80100bc9:	53                   	push   %ebx
80100bca:	57                   	push   %edi
80100bcb:	e8 44 5b 00 00       	call   80106714 <copyout>
80100bd0:	83 c4 20             	add    $0x20,%esp
80100bd3:	85 c0                	test   %eax,%eax
80100bd5:	79 b1                	jns    80100b88 <exec+0x1e4>
80100bd7:	90                   	nop
    freevm(pgdir);
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100be1:	e8 ee 58 00 00       	call   801064d4 <freevm>
80100be6:	83 c4 10             	add    $0x10,%esp
  return -1;
80100be9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bee:	e9 1d fe ff ff       	jmp    80100a10 <exec+0x6c>
80100bf3:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
  ustack[3+argc] = 0;
80100bf9:	c7 84 b5 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%esi,4)
80100c00:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100c04:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100c0b:	ff ff ff 
  ustack[1] = argc;
80100c0e:	89 b5 5c ff ff ff    	mov    %esi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100c14:	8d 04 b5 04 00 00 00 	lea    0x4(,%esi,4),%eax
80100c1b:	89 d9                	mov    %ebx,%ecx
80100c1d:	29 c1                	sub    %eax,%ecx
80100c1f:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100c25:	83 c0 0c             	add    $0xc,%eax
80100c28:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100c2a:	50                   	push   %eax
80100c2b:	52                   	push   %edx
80100c2c:	53                   	push   %ebx
80100c2d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100c33:	e8 dc 5a 00 00       	call   80106714 <copyout>
80100c38:	83 c4 10             	add    $0x10,%esp
80100c3b:	85 c0                	test   %eax,%eax
80100c3d:	78 99                	js     80100bd8 <exec+0x234>
  for(last=s=path; *s; s++)
80100c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80100c42:	8a 00                	mov    (%eax),%al
80100c44:	8b 55 08             	mov    0x8(%ebp),%edx
80100c47:	84 c0                	test   %al,%al
80100c49:	74 12                	je     80100c5d <exec+0x2b9>
80100c4b:	89 d1                	mov    %edx,%ecx
80100c4d:	8d 76 00             	lea    0x0(%esi),%esi
    if(*s == '/')
80100c50:	41                   	inc    %ecx
80100c51:	3c 2f                	cmp    $0x2f,%al
80100c53:	75 02                	jne    80100c57 <exec+0x2b3>
80100c55:	89 ca                	mov    %ecx,%edx
  for(last=s=path; *s; s++)
80100c57:	8a 01                	mov    (%ecx),%al
80100c59:	84 c0                	test   %al,%al
80100c5b:	75 f3                	jne    80100c50 <exec+0x2ac>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100c5d:	50                   	push   %eax
80100c5e:	6a 10                	push   $0x10
80100c60:	52                   	push   %edx
80100c61:	8b b5 ec fe ff ff    	mov    -0x114(%ebp),%esi
80100c67:	89 f0                	mov    %esi,%eax
80100c69:	83 c0 6c             	add    $0x6c,%eax
80100c6c:	50                   	push   %eax
80100c6d:	e8 0e 36 00 00       	call   80104280 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100c72:	89 f0                	mov    %esi,%eax
80100c74:	8b 76 04             	mov    0x4(%esi),%esi
  curproc->pgdir = pgdir;
80100c77:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c7d:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100c80:	89 38                	mov    %edi,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100c82:	89 c7                	mov    %eax,%edi
80100c84:	8b 40 18             	mov    0x18(%eax),%eax
80100c87:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100c8d:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100c90:	8b 47 18             	mov    0x18(%edi),%eax
80100c93:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100c96:	89 3c 24             	mov    %edi,(%esp)
80100c99:	e8 c6 54 00 00       	call   80106164 <switchuvm>
  freevm(oldpgdir);
80100c9e:	89 34 24             	mov    %esi,(%esp)
80100ca1:	e8 2e 58 00 00       	call   801064d4 <freevm>
  return 0;
80100ca6:	83 c4 10             	add    $0x10,%esp
80100ca9:	31 c0                	xor    %eax,%eax
80100cab:	e9 60 fd ff ff       	jmp    80100a10 <exec+0x6c>
    end_op();
80100cb0:	e8 ef 1b 00 00       	call   801028a4 <end_op>
    cprintf("exec: fail\n");
80100cb5:	83 ec 0c             	sub    $0xc,%esp
80100cb8:	68 21 68 10 80       	push   $0x80106821
80100cbd:	e8 5e f9 ff ff       	call   80100620 <cprintf>
    return -1;
80100cc2:	83 c4 10             	add    $0x10,%esp
80100cc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cca:	e9 41 fd ff ff       	jmp    80100a10 <exec+0x6c>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ccf:	be 00 20 00 00       	mov    $0x2000,%esi
80100cd4:	e9 49 fe ff ff       	jmp    80100b22 <exec+0x17e>
80100cd9:	66 90                	xchg   %ax,%ax
80100cdb:	90                   	nop

80100cdc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100cdc:	55                   	push   %ebp
80100cdd:	89 e5                	mov    %esp,%ebp
80100cdf:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100ce2:	68 2d 68 10 80       	push   $0x8010682d
80100ce7:	68 a0 09 11 80       	push   $0x801109a0
80100cec:	e8 1b 32 00 00       	call   80103f0c <initlock>
}
80100cf1:	83 c4 10             	add    $0x10,%esp
80100cf4:	c9                   	leave  
80100cf5:	c3                   	ret    
80100cf6:	66 90                	xchg   %ax,%ax

80100cf8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100cf8:	55                   	push   %ebp
80100cf9:	89 e5                	mov    %esp,%ebp
80100cfb:	83 ec 24             	sub    $0x24,%esp
  struct file *f;

  acquire(&ftable.lock);
80100cfe:	68 a0 09 11 80       	push   $0x801109a0
80100d03:	e8 44 33 00 00       	call   8010404c <acquire>
80100d08:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100d0b:	b8 d4 09 11 80       	mov    $0x801109d4,%eax
80100d10:	eb 0c                	jmp    80100d1e <filealloc+0x26>
80100d12:	66 90                	xchg   %ax,%ax
80100d14:	83 c0 18             	add    $0x18,%eax
80100d17:	3d 34 13 11 80       	cmp    $0x80111334,%eax
80100d1c:	74 26                	je     80100d44 <filealloc+0x4c>
    if(f->ref == 0){
80100d1e:	8b 50 04             	mov    0x4(%eax),%edx
80100d21:	85 d2                	test   %edx,%edx
80100d23:	75 ef                	jne    80100d14 <filealloc+0x1c>
      f->ref = 1;
80100d25:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
80100d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      release(&ftable.lock);
80100d2f:	83 ec 0c             	sub    $0xc,%esp
80100d32:	68 a0 09 11 80       	push   $0x801109a0
80100d37:	e8 a8 33 00 00       	call   801040e4 <release>
      return f;
80100d3c:	83 c4 10             	add    $0x10,%esp
80100d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    }
  }
  release(&ftable.lock);
  return 0;
}
80100d42:	c9                   	leave  
80100d43:	c3                   	ret    
  release(&ftable.lock);
80100d44:	83 ec 0c             	sub    $0xc,%esp
80100d47:	68 a0 09 11 80       	push   $0x801109a0
80100d4c:	e8 93 33 00 00       	call   801040e4 <release>
  return 0;
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	31 c0                	xor    %eax,%eax
}
80100d56:	c9                   	leave  
80100d57:	c3                   	ret    

80100d58 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100d58:	55                   	push   %ebp
80100d59:	89 e5                	mov    %esp,%ebp
80100d5b:	53                   	push   %ebx
80100d5c:	83 ec 10             	sub    $0x10,%esp
80100d5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100d62:	68 a0 09 11 80       	push   $0x801109a0
80100d67:	e8 e0 32 00 00       	call   8010404c <acquire>
  if(f->ref < 1)
80100d6c:	8b 43 04             	mov    0x4(%ebx),%eax
80100d6f:	83 c4 10             	add    $0x10,%esp
80100d72:	85 c0                	test   %eax,%eax
80100d74:	7e 18                	jle    80100d8e <filedup+0x36>
    panic("filedup");
  f->ref++;
80100d76:	40                   	inc    %eax
80100d77:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100d7a:	83 ec 0c             	sub    $0xc,%esp
80100d7d:	68 a0 09 11 80       	push   $0x801109a0
80100d82:	e8 5d 33 00 00       	call   801040e4 <release>
  return f;
}
80100d87:	89 d8                	mov    %ebx,%eax
80100d89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d8c:	c9                   	leave  
80100d8d:	c3                   	ret    
    panic("filedup");
80100d8e:	83 ec 0c             	sub    $0xc,%esp
80100d91:	68 34 68 10 80       	push   $0x80106834
80100d96:	e8 a5 f5 ff ff       	call   80100340 <panic>
80100d9b:	90                   	nop

80100d9c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100d9c:	55                   	push   %ebp
80100d9d:	89 e5                	mov    %esp,%ebp
80100d9f:	57                   	push   %edi
80100da0:	56                   	push   %esi
80100da1:	53                   	push   %ebx
80100da2:	83 ec 28             	sub    $0x28,%esp
80100da5:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct file ff;

  acquire(&ftable.lock);
80100da8:	68 a0 09 11 80       	push   $0x801109a0
80100dad:	e8 9a 32 00 00       	call   8010404c <acquire>
  if(f->ref < 1)
80100db2:	8b 57 04             	mov    0x4(%edi),%edx
80100db5:	83 c4 10             	add    $0x10,%esp
80100db8:	85 d2                	test   %edx,%edx
80100dba:	0f 8e 8d 00 00 00    	jle    80100e4d <fileclose+0xb1>
    panic("fileclose");
  if(--f->ref > 0){
80100dc0:	4a                   	dec    %edx
80100dc1:	89 57 04             	mov    %edx,0x4(%edi)
80100dc4:	75 3a                	jne    80100e00 <fileclose+0x64>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100dc6:	8b 1f                	mov    (%edi),%ebx
80100dc8:	8a 47 09             	mov    0x9(%edi),%al
80100dcb:	88 45 e7             	mov    %al,-0x19(%ebp)
80100dce:	8b 77 0c             	mov    0xc(%edi),%esi
80100dd1:	8b 47 10             	mov    0x10(%edi),%eax
80100dd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  f->ref = 0;
  f->type = FD_NONE;
80100dd7:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  release(&ftable.lock);
80100ddd:	83 ec 0c             	sub    $0xc,%esp
80100de0:	68 a0 09 11 80       	push   $0x801109a0
80100de5:	e8 fa 32 00 00       	call   801040e4 <release>

  if(ff.type == FD_PIPE)
80100dea:	83 c4 10             	add    $0x10,%esp
80100ded:	83 fb 01             	cmp    $0x1,%ebx
80100df0:	74 42                	je     80100e34 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100df2:	83 fb 02             	cmp    $0x2,%ebx
80100df5:	74 1d                	je     80100e14 <fileclose+0x78>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100df7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100dfa:	5b                   	pop    %ebx
80100dfb:	5e                   	pop    %esi
80100dfc:	5f                   	pop    %edi
80100dfd:	5d                   	pop    %ebp
80100dfe:	c3                   	ret    
80100dff:	90                   	nop
    release(&ftable.lock);
80100e00:	c7 45 08 a0 09 11 80 	movl   $0x801109a0,0x8(%ebp)
}
80100e07:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100e0a:	5b                   	pop    %ebx
80100e0b:	5e                   	pop    %esi
80100e0c:	5f                   	pop    %edi
80100e0d:	5d                   	pop    %ebp
    release(&ftable.lock);
80100e0e:	e9 d1 32 00 00       	jmp    801040e4 <release>
80100e13:	90                   	nop
    begin_op();
80100e14:	e8 23 1a 00 00       	call   8010283c <begin_op>
    iput(ff.ip);
80100e19:	83 ec 0c             	sub    $0xc,%esp
80100e1c:	ff 75 e0             	pushl  -0x20(%ebp)
80100e1f:	e8 44 08 00 00       	call   80101668 <iput>
    end_op();
80100e24:	83 c4 10             	add    $0x10,%esp
}
80100e27:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100e2a:	5b                   	pop    %ebx
80100e2b:	5e                   	pop    %esi
80100e2c:	5f                   	pop    %edi
80100e2d:	5d                   	pop    %ebp
    end_op();
80100e2e:	e9 71 1a 00 00       	jmp    801028a4 <end_op>
80100e33:	90                   	nop
    pipeclose(ff.pipe, ff.writable);
80100e34:	83 ec 08             	sub    $0x8,%esp
80100e37:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
80100e3b:	50                   	push   %eax
80100e3c:	56                   	push   %esi
80100e3d:	e8 ee 20 00 00       	call   80102f30 <pipeclose>
80100e42:	83 c4 10             	add    $0x10,%esp
}
80100e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100e48:	5b                   	pop    %ebx
80100e49:	5e                   	pop    %esi
80100e4a:	5f                   	pop    %edi
80100e4b:	5d                   	pop    %ebp
80100e4c:	c3                   	ret    
    panic("fileclose");
80100e4d:	83 ec 0c             	sub    $0xc,%esp
80100e50:	68 3c 68 10 80       	push   $0x8010683c
80100e55:	e8 e6 f4 ff ff       	call   80100340 <panic>
80100e5a:	66 90                	xchg   %ax,%ax

80100e5c <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100e5c:	55                   	push   %ebp
80100e5d:	89 e5                	mov    %esp,%ebp
80100e5f:	53                   	push   %ebx
80100e60:	53                   	push   %ebx
80100e61:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100e64:	83 3b 02             	cmpl   $0x2,(%ebx)
80100e67:	75 2b                	jne    80100e94 <filestat+0x38>
    ilock(f->ip);
80100e69:	83 ec 0c             	sub    $0xc,%esp
80100e6c:	ff 73 10             	pushl  0x10(%ebx)
80100e6f:	e8 e8 06 00 00       	call   8010155c <ilock>
    stati(f->ip, st);
80100e74:	58                   	pop    %eax
80100e75:	5a                   	pop    %edx
80100e76:	ff 75 0c             	pushl  0xc(%ebp)
80100e79:	ff 73 10             	pushl  0x10(%ebx)
80100e7c:	e8 53 09 00 00       	call   801017d4 <stati>
    iunlock(f->ip);
80100e81:	59                   	pop    %ecx
80100e82:	ff 73 10             	pushl  0x10(%ebx)
80100e85:	e8 9a 07 00 00       	call   80101624 <iunlock>
    return 0;
80100e8a:	83 c4 10             	add    $0x10,%esp
80100e8d:	31 c0                	xor    %eax,%eax
  }
  return -1;
}
80100e8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e92:	c9                   	leave  
80100e93:	c3                   	ret    
  return -1;
80100e94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100e99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e9c:	c9                   	leave  
80100e9d:	c3                   	ret    
80100e9e:	66 90                	xchg   %ax,%ax

80100ea0 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100ea0:	55                   	push   %ebp
80100ea1:	89 e5                	mov    %esp,%ebp
80100ea3:	57                   	push   %edi
80100ea4:	56                   	push   %esi
80100ea5:	53                   	push   %ebx
80100ea6:	83 ec 1c             	sub    $0x1c,%esp
80100ea9:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100eac:	8b 75 0c             	mov    0xc(%ebp),%esi
80100eaf:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80100eb2:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100eb6:	74 60                	je     80100f18 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80100eb8:	8b 03                	mov    (%ebx),%eax
80100eba:	83 f8 01             	cmp    $0x1,%eax
80100ebd:	74 45                	je     80100f04 <fileread+0x64>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100ebf:	83 f8 02             	cmp    $0x2,%eax
80100ec2:	75 5b                	jne    80100f1f <fileread+0x7f>
    ilock(f->ip);
80100ec4:	83 ec 0c             	sub    $0xc,%esp
80100ec7:	ff 73 10             	pushl  0x10(%ebx)
80100eca:	e8 8d 06 00 00       	call   8010155c <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100ecf:	57                   	push   %edi
80100ed0:	ff 73 14             	pushl  0x14(%ebx)
80100ed3:	56                   	push   %esi
80100ed4:	ff 73 10             	pushl  0x10(%ebx)
80100ed7:	e8 24 09 00 00       	call   80101800 <readi>
80100edc:	83 c4 20             	add    $0x20,%esp
80100edf:	85 c0                	test   %eax,%eax
80100ee1:	7e 03                	jle    80100ee6 <fileread+0x46>
      f->off += r;
80100ee3:	01 43 14             	add    %eax,0x14(%ebx)
80100ee6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    iunlock(f->ip);
80100ee9:	83 ec 0c             	sub    $0xc,%esp
80100eec:	ff 73 10             	pushl  0x10(%ebx)
80100eef:	e8 30 07 00 00       	call   80101624 <iunlock>
    return r;
80100ef4:	83 c4 10             	add    $0x10,%esp
80100ef7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("fileread");
}
80100efa:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100efd:	5b                   	pop    %ebx
80100efe:	5e                   	pop    %esi
80100eff:	5f                   	pop    %edi
80100f00:	5d                   	pop    %ebp
80100f01:	c3                   	ret    
80100f02:	66 90                	xchg   %ax,%ax
    return piperead(f->pipe, addr, n);
80100f04:	8b 43 0c             	mov    0xc(%ebx),%eax
80100f07:	89 45 08             	mov    %eax,0x8(%ebp)
}
80100f0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f0d:	5b                   	pop    %ebx
80100f0e:	5e                   	pop    %esi
80100f0f:	5f                   	pop    %edi
80100f10:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
80100f11:	e9 a2 21 00 00       	jmp    801030b8 <piperead>
80100f16:	66 90                	xchg   %ax,%ax
    return -1;
80100f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f1d:	eb db                	jmp    80100efa <fileread+0x5a>
  panic("fileread");
80100f1f:	83 ec 0c             	sub    $0xc,%esp
80100f22:	68 46 68 10 80       	push   $0x80106846
80100f27:	e8 14 f4 ff ff       	call   80100340 <panic>

80100f2c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100f2c:	55                   	push   %ebp
80100f2d:	89 e5                	mov    %esp,%ebp
80100f2f:	57                   	push   %edi
80100f30:	56                   	push   %esi
80100f31:	53                   	push   %ebx
80100f32:	83 ec 1c             	sub    $0x1c,%esp
80100f35:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100f38:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f3b:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100f3e:	8b 45 10             	mov    0x10(%ebp),%eax
80100f41:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int r;

  if(f->writable == 0)
80100f44:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100f48:	0f 84 ae 00 00 00    	je     80100ffc <filewrite+0xd0>
    return -1;
  if(f->type == FD_PIPE)
80100f4e:	8b 03                	mov    (%ebx),%eax
80100f50:	83 f8 01             	cmp    $0x1,%eax
80100f53:	0f 84 c2 00 00 00    	je     8010101b <filewrite+0xef>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100f59:	83 f8 02             	cmp    $0x2,%eax
80100f5c:	0f 85 cb 00 00 00    	jne    8010102d <filewrite+0x101>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100f62:	31 ff                	xor    %edi,%edi
    while(i < n){
80100f64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f67:	85 c0                	test   %eax,%eax
80100f69:	7f 2c                	jg     80100f97 <filewrite+0x6b>
80100f6b:	e9 9c 00 00 00       	jmp    8010100c <filewrite+0xe0>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80100f70:	01 43 14             	add    %eax,0x14(%ebx)
80100f73:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80100f76:	83 ec 0c             	sub    $0xc,%esp
80100f79:	ff 73 10             	pushl  0x10(%ebx)
80100f7c:	e8 a3 06 00 00       	call   80101624 <iunlock>
      end_op();
80100f81:	e8 1e 19 00 00       	call   801028a4 <end_op>

      if(r < 0)
        break;
      if(r != n1)
80100f86:	83 c4 10             	add    $0x10,%esp
80100f89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f8c:	39 c6                	cmp    %eax,%esi
80100f8e:	75 5f                	jne    80100fef <filewrite+0xc3>
        panic("short filewrite");
      i += r;
80100f90:	01 f7                	add    %esi,%edi
    while(i < n){
80100f92:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80100f95:	7e 75                	jle    8010100c <filewrite+0xe0>
      if(n1 > max)
80100f97:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80100f9a:	29 fe                	sub    %edi,%esi
80100f9c:	81 fe 00 06 00 00    	cmp    $0x600,%esi
80100fa2:	7e 05                	jle    80100fa9 <filewrite+0x7d>
80100fa4:	be 00 06 00 00       	mov    $0x600,%esi
      begin_op();
80100fa9:	e8 8e 18 00 00       	call   8010283c <begin_op>
      ilock(f->ip);
80100fae:	83 ec 0c             	sub    $0xc,%esp
80100fb1:	ff 73 10             	pushl  0x10(%ebx)
80100fb4:	e8 a3 05 00 00       	call   8010155c <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100fb9:	56                   	push   %esi
80100fba:	ff 73 14             	pushl  0x14(%ebx)
80100fbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100fc0:	01 f8                	add    %edi,%eax
80100fc2:	50                   	push   %eax
80100fc3:	ff 73 10             	pushl  0x10(%ebx)
80100fc6:	e8 2d 09 00 00       	call   801018f8 <writei>
80100fcb:	83 c4 20             	add    $0x20,%esp
80100fce:	85 c0                	test   %eax,%eax
80100fd0:	7f 9e                	jg     80100f70 <filewrite+0x44>
80100fd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      iunlock(f->ip);
80100fd5:	83 ec 0c             	sub    $0xc,%esp
80100fd8:	ff 73 10             	pushl  0x10(%ebx)
80100fdb:	e8 44 06 00 00       	call   80101624 <iunlock>
      end_op();
80100fe0:	e8 bf 18 00 00       	call   801028a4 <end_op>
      if(r < 0)
80100fe5:	83 c4 10             	add    $0x10,%esp
80100fe8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100feb:	85 c0                	test   %eax,%eax
80100fed:	75 0d                	jne    80100ffc <filewrite+0xd0>
        panic("short filewrite");
80100fef:	83 ec 0c             	sub    $0xc,%esp
80100ff2:	68 4f 68 10 80       	push   $0x8010684f
80100ff7:	e8 44 f3 ff ff       	call   80100340 <panic>
    }
    return i == n ? n : -1;
80100ffc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80101001:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101004:	5b                   	pop    %ebx
80101005:	5e                   	pop    %esi
80101006:	5f                   	pop    %edi
80101007:	5d                   	pop    %ebp
80101008:	c3                   	ret    
80101009:	8d 76 00             	lea    0x0(%esi),%esi
    return i == n ? n : -1;
8010100c:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
8010100f:	75 eb                	jne    80100ffc <filewrite+0xd0>
80101011:	89 f8                	mov    %edi,%eax
}
80101013:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101016:	5b                   	pop    %ebx
80101017:	5e                   	pop    %esi
80101018:	5f                   	pop    %edi
80101019:	5d                   	pop    %ebp
8010101a:	c3                   	ret    
    return pipewrite(f->pipe, addr, n);
8010101b:	8b 43 0c             	mov    0xc(%ebx),%eax
8010101e:	89 45 08             	mov    %eax,0x8(%ebp)
}
80101021:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101024:	5b                   	pop    %ebx
80101025:	5e                   	pop    %esi
80101026:	5f                   	pop    %edi
80101027:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
80101028:	e9 9b 1f 00 00       	jmp    80102fc8 <pipewrite>
  panic("filewrite");
8010102d:	83 ec 0c             	sub    $0xc,%esp
80101030:	68 55 68 10 80       	push   $0x80106855
80101035:	e8 06 f3 ff ff       	call   80100340 <panic>
8010103a:	66 90                	xchg   %ax,%ax

8010103c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010103c:	55                   	push   %ebp
8010103d:	89 e5                	mov    %esp,%ebp
8010103f:	56                   	push   %esi
80101040:	53                   	push   %ebx
80101041:	89 c1                	mov    %eax,%ecx
80101043:	89 d3                	mov    %edx,%ebx
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
80101045:	83 ec 08             	sub    $0x8,%esp
80101048:	89 d0                	mov    %edx,%eax
8010104a:	c1 e8 0c             	shr    $0xc,%eax
8010104d:	03 05 b8 13 11 80    	add    0x801113b8,%eax
80101053:	50                   	push   %eax
80101054:	51                   	push   %ecx
80101055:	e8 5a f0 ff ff       	call   801000b4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
8010105a:	89 d9                	mov    %ebx,%ecx
8010105c:	83 e1 07             	and    $0x7,%ecx
8010105f:	ba 01 00 00 00       	mov    $0x1,%edx
80101064:	d3 e2                	shl    %cl,%edx
  if((bp->data[bi/8] & m) == 0)
80101066:	c1 fb 03             	sar    $0x3,%ebx
80101069:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
8010106f:	0f b6 4c 18 5c       	movzbl 0x5c(%eax,%ebx,1),%ecx
80101074:	83 c4 10             	add    $0x10,%esp
80101077:	85 d1                	test   %edx,%ecx
80101079:	74 25                	je     801010a0 <bfree+0x64>
8010107b:	89 c6                	mov    %eax,%esi
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
8010107d:	f7 d2                	not    %edx
8010107f:	21 ca                	and    %ecx,%edx
80101081:	88 54 18 5c          	mov    %dl,0x5c(%eax,%ebx,1)
  log_write(bp);
80101085:	83 ec 0c             	sub    $0xc,%esp
80101088:	50                   	push   %eax
80101089:	e8 6a 19 00 00       	call   801029f8 <log_write>
  brelse(bp);
8010108e:	89 34 24             	mov    %esi,(%esp)
80101091:	e8 2a f1 ff ff       	call   801001c0 <brelse>
}
80101096:	83 c4 10             	add    $0x10,%esp
80101099:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010109c:	5b                   	pop    %ebx
8010109d:	5e                   	pop    %esi
8010109e:	5d                   	pop    %ebp
8010109f:	c3                   	ret    
    panic("freeing free block");
801010a0:	83 ec 0c             	sub    $0xc,%esp
801010a3:	68 5f 68 10 80       	push   $0x8010685f
801010a8:	e8 93 f2 ff ff       	call   80100340 <panic>
801010ad:	8d 76 00             	lea    0x0(%esi),%esi

801010b0 <balloc>:
{
801010b0:	55                   	push   %ebp
801010b1:	89 e5                	mov    %esp,%ebp
801010b3:	57                   	push   %edi
801010b4:	56                   	push   %esi
801010b5:	53                   	push   %ebx
801010b6:	83 ec 1c             	sub    $0x1c,%esp
801010b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801010bc:	8b 0d a0 13 11 80    	mov    0x801113a0,%ecx
801010c2:	85 c9                	test   %ecx,%ecx
801010c4:	74 7e                	je     80101144 <balloc+0x94>
801010c6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
801010cd:	83 ec 08             	sub    $0x8,%esp
801010d0:	8b 75 dc             	mov    -0x24(%ebp),%esi
801010d3:	89 f0                	mov    %esi,%eax
801010d5:	c1 f8 0c             	sar    $0xc,%eax
801010d8:	03 05 b8 13 11 80    	add    0x801113b8,%eax
801010de:	50                   	push   %eax
801010df:	ff 75 d8             	pushl  -0x28(%ebp)
801010e2:	e8 cd ef ff ff       	call   801000b4 <bread>
801010e7:	89 c3                	mov    %eax,%ebx
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801010e9:	a1 a0 13 11 80       	mov    0x801113a0,%eax
801010ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
801010f1:	83 c4 10             	add    $0x10,%esp
801010f4:	31 c0                	xor    %eax,%eax
801010f6:	eb 29                	jmp    80101121 <balloc+0x71>
      m = 1 << (bi % 8);
801010f8:	89 c1                	mov    %eax,%ecx
801010fa:	83 e1 07             	and    $0x7,%ecx
801010fd:	bf 01 00 00 00       	mov    $0x1,%edi
80101102:	d3 e7                	shl    %cl,%edi
80101104:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101107:	89 c1                	mov    %eax,%ecx
80101109:	c1 f9 03             	sar    $0x3,%ecx
8010110c:	0f b6 7c 0b 5c       	movzbl 0x5c(%ebx,%ecx,1),%edi
80101111:	89 fa                	mov    %edi,%edx
80101113:	85 7d e4             	test   %edi,-0x1c(%ebp)
80101116:	74 3c                	je     80101154 <balloc+0xa4>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101118:	40                   	inc    %eax
80101119:	46                   	inc    %esi
8010111a:	3d 00 10 00 00       	cmp    $0x1000,%eax
8010111f:	74 05                	je     80101126 <balloc+0x76>
80101121:	39 75 e0             	cmp    %esi,-0x20(%ebp)
80101124:	77 d2                	ja     801010f8 <balloc+0x48>
    brelse(bp);
80101126:	83 ec 0c             	sub    $0xc,%esp
80101129:	53                   	push   %ebx
8010112a:	e8 91 f0 ff ff       	call   801001c0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
8010112f:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
80101136:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101139:	83 c4 10             	add    $0x10,%esp
8010113c:	39 05 a0 13 11 80    	cmp    %eax,0x801113a0
80101142:	77 89                	ja     801010cd <balloc+0x1d>
  panic("balloc: out of blocks");
80101144:	83 ec 0c             	sub    $0xc,%esp
80101147:	68 72 68 10 80       	push   $0x80106872
8010114c:	e8 ef f1 ff ff       	call   80100340 <panic>
80101151:	8d 76 00             	lea    0x0(%esi),%esi
        bp->data[bi/8] |= m;  // Mark block in use.
80101154:	0b 55 e4             	or     -0x1c(%ebp),%edx
80101157:	88 54 0b 5c          	mov    %dl,0x5c(%ebx,%ecx,1)
        log_write(bp);
8010115b:	83 ec 0c             	sub    $0xc,%esp
8010115e:	53                   	push   %ebx
8010115f:	e8 94 18 00 00       	call   801029f8 <log_write>
        brelse(bp);
80101164:	89 1c 24             	mov    %ebx,(%esp)
80101167:	e8 54 f0 ff ff       	call   801001c0 <brelse>
  bp = bread(dev, bno);
8010116c:	58                   	pop    %eax
8010116d:	5a                   	pop    %edx
8010116e:	56                   	push   %esi
8010116f:	ff 75 d8             	pushl  -0x28(%ebp)
80101172:	e8 3d ef ff ff       	call   801000b4 <bread>
80101177:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80101179:	83 c4 0c             	add    $0xc,%esp
8010117c:	68 00 02 00 00       	push   $0x200
80101181:	6a 00                	push   $0x0
80101183:	8d 40 5c             	lea    0x5c(%eax),%eax
80101186:	50                   	push   %eax
80101187:	e8 a0 2f 00 00       	call   8010412c <memset>
  log_write(bp);
8010118c:	89 1c 24             	mov    %ebx,(%esp)
8010118f:	e8 64 18 00 00       	call   801029f8 <log_write>
  brelse(bp);
80101194:	89 1c 24             	mov    %ebx,(%esp)
80101197:	e8 24 f0 ff ff       	call   801001c0 <brelse>
}
8010119c:	89 f0                	mov    %esi,%eax
8010119e:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011a1:	5b                   	pop    %ebx
801011a2:	5e                   	pop    %esi
801011a3:	5f                   	pop    %edi
801011a4:	5d                   	pop    %ebp
801011a5:	c3                   	ret    
801011a6:	66 90                	xchg   %ax,%ax

801011a8 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801011a8:	55                   	push   %ebp
801011a9:	89 e5                	mov    %esp,%ebp
801011ab:	57                   	push   %edi
801011ac:	56                   	push   %esi
801011ad:	53                   	push   %ebx
801011ae:	83 ec 28             	sub    $0x28,%esp
801011b1:	89 c6                	mov    %eax,%esi
801011b3:	89 d7                	mov    %edx,%edi
  struct inode *ip, *empty;

  acquire(&icache.lock);
801011b5:	68 c0 13 11 80       	push   $0x801113c0
801011ba:	e8 8d 2e 00 00       	call   8010404c <acquire>
801011bf:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801011c2:	31 c0                	xor    %eax,%eax
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011c4:	bb f4 13 11 80       	mov    $0x801113f4,%ebx
801011c9:	eb 13                	jmp    801011de <iget+0x36>
801011cb:	90                   	nop
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801011cc:	39 33                	cmp    %esi,(%ebx)
801011ce:	74 68                	je     80101238 <iget+0x90>
801011d0:	81 c3 90 00 00 00    	add    $0x90,%ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011d6:	81 fb 14 30 11 80    	cmp    $0x80113014,%ebx
801011dc:	73 22                	jae    80101200 <iget+0x58>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801011de:	8b 4b 08             	mov    0x8(%ebx),%ecx
801011e1:	85 c9                	test   %ecx,%ecx
801011e3:	7f e7                	jg     801011cc <iget+0x24>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011e5:	85 c0                	test   %eax,%eax
801011e7:	75 e7                	jne    801011d0 <iget+0x28>
801011e9:	89 da                	mov    %ebx,%edx
801011eb:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011f1:	85 c9                	test   %ecx,%ecx
801011f3:	75 66                	jne    8010125b <iget+0xb3>
801011f5:	89 d0                	mov    %edx,%eax
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011f7:	81 fb 14 30 11 80    	cmp    $0x80113014,%ebx
801011fd:	72 df                	jb     801011de <iget+0x36>
801011ff:	90                   	nop
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101200:	85 c0                	test   %eax,%eax
80101202:	74 6f                	je     80101273 <iget+0xcb>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
80101204:	89 30                	mov    %esi,(%eax)
  ip->inum = inum;
80101206:	89 78 04             	mov    %edi,0x4(%eax)
  ip->ref = 1;
80101209:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101210:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
80101217:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  release(&icache.lock);
8010121a:	83 ec 0c             	sub    $0xc,%esp
8010121d:	68 c0 13 11 80       	push   $0x801113c0
80101222:	e8 bd 2e 00 00       	call   801040e4 <release>

  return ip;
80101227:	83 c4 10             	add    $0x10,%esp
8010122a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
8010122d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101230:	5b                   	pop    %ebx
80101231:	5e                   	pop    %esi
80101232:	5f                   	pop    %edi
80101233:	5d                   	pop    %ebp
80101234:	c3                   	ret    
80101235:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101238:	39 7b 04             	cmp    %edi,0x4(%ebx)
8010123b:	75 93                	jne    801011d0 <iget+0x28>
      ip->ref++;
8010123d:	41                   	inc    %ecx
8010123e:	89 4b 08             	mov    %ecx,0x8(%ebx)
      release(&icache.lock);
80101241:	83 ec 0c             	sub    $0xc,%esp
80101244:	68 c0 13 11 80       	push   $0x801113c0
80101249:	e8 96 2e 00 00       	call   801040e4 <release>
      return ip;
8010124e:	83 c4 10             	add    $0x10,%esp
80101251:	89 d8                	mov    %ebx,%eax
}
80101253:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101256:	5b                   	pop    %ebx
80101257:	5e                   	pop    %esi
80101258:	5f                   	pop    %edi
80101259:	5d                   	pop    %ebp
8010125a:	c3                   	ret    
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010125b:	81 fb 14 30 11 80    	cmp    $0x80113014,%ebx
80101261:	73 10                	jae    80101273 <iget+0xcb>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101263:	8b 4b 08             	mov    0x8(%ebx),%ecx
80101266:	85 c9                	test   %ecx,%ecx
80101268:	0f 8f 5e ff ff ff    	jg     801011cc <iget+0x24>
8010126e:	e9 76 ff ff ff       	jmp    801011e9 <iget+0x41>
    panic("iget: no inodes");
80101273:	83 ec 0c             	sub    $0xc,%esp
80101276:	68 88 68 10 80       	push   $0x80106888
8010127b:	e8 c0 f0 ff ff       	call   80100340 <panic>

80101280 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101280:	55                   	push   %ebp
80101281:	89 e5                	mov    %esp,%ebp
80101283:	57                   	push   %edi
80101284:	56                   	push   %esi
80101285:	53                   	push   %ebx
80101286:	83 ec 1c             	sub    $0x1c,%esp
80101289:	89 c6                	mov    %eax,%esi
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010128b:	83 fa 0b             	cmp    $0xb,%edx
8010128e:	0f 86 80 00 00 00    	jbe    80101314 <bmap+0x94>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80101294:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
80101297:	83 fb 7f             	cmp    $0x7f,%ebx
8010129a:	0f 87 90 00 00 00    	ja     80101330 <bmap+0xb0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
801012a0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801012a6:	8b 16                	mov    (%esi),%edx
801012a8:	85 c0                	test   %eax,%eax
801012aa:	74 54                	je     80101300 <bmap+0x80>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
801012ac:	83 ec 08             	sub    $0x8,%esp
801012af:	50                   	push   %eax
801012b0:	52                   	push   %edx
801012b1:	e8 fe ed ff ff       	call   801000b4 <bread>
801012b6:	89 c7                	mov    %eax,%edi
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
801012b8:	8d 5c 98 5c          	lea    0x5c(%eax,%ebx,4),%ebx
801012bc:	8b 03                	mov    (%ebx),%eax
801012be:	83 c4 10             	add    $0x10,%esp
801012c1:	85 c0                	test   %eax,%eax
801012c3:	74 1b                	je     801012e0 <bmap+0x60>
801012c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
801012c8:	83 ec 0c             	sub    $0xc,%esp
801012cb:	57                   	push   %edi
801012cc:	e8 ef ee ff ff       	call   801001c0 <brelse>
    return addr;
801012d1:	83 c4 10             	add    $0x10,%esp
801012d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }

  panic("bmap: out of range");
}
801012d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012da:	5b                   	pop    %ebx
801012db:	5e                   	pop    %esi
801012dc:	5f                   	pop    %edi
801012dd:	5d                   	pop    %ebp
801012de:	c3                   	ret    
801012df:	90                   	nop
      a[bn] = addr = balloc(ip->dev);
801012e0:	8b 06                	mov    (%esi),%eax
801012e2:	e8 c9 fd ff ff       	call   801010b0 <balloc>
801012e7:	89 03                	mov    %eax,(%ebx)
801012e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      log_write(bp);
801012ec:	83 ec 0c             	sub    $0xc,%esp
801012ef:	57                   	push   %edi
801012f0:	e8 03 17 00 00       	call   801029f8 <log_write>
801012f5:	83 c4 10             	add    $0x10,%esp
801012f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801012fb:	eb c8                	jmp    801012c5 <bmap+0x45>
801012fd:	8d 76 00             	lea    0x0(%esi),%esi
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101300:	89 d0                	mov    %edx,%eax
80101302:	e8 a9 fd ff ff       	call   801010b0 <balloc>
80101307:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
8010130d:	8b 16                	mov    (%esi),%edx
8010130f:	eb 9b                	jmp    801012ac <bmap+0x2c>
80101311:	8d 76 00             	lea    0x0(%esi),%esi
    if((addr = ip->addrs[bn]) == 0)
80101314:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
80101317:	8b 43 5c             	mov    0x5c(%ebx),%eax
8010131a:	85 c0                	test   %eax,%eax
8010131c:	75 b9                	jne    801012d7 <bmap+0x57>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010131e:	8b 06                	mov    (%esi),%eax
80101320:	e8 8b fd ff ff       	call   801010b0 <balloc>
80101325:	89 43 5c             	mov    %eax,0x5c(%ebx)
}
80101328:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010132b:	5b                   	pop    %ebx
8010132c:	5e                   	pop    %esi
8010132d:	5f                   	pop    %edi
8010132e:	5d                   	pop    %ebp
8010132f:	c3                   	ret    
  panic("bmap: out of range");
80101330:	83 ec 0c             	sub    $0xc,%esp
80101333:	68 98 68 10 80       	push   $0x80106898
80101338:	e8 03 f0 ff ff       	call   80100340 <panic>
8010133d:	8d 76 00             	lea    0x0(%esi),%esi

80101340 <readsb>:
{
80101340:	55                   	push   %ebp
80101341:	89 e5                	mov    %esp,%ebp
80101343:	56                   	push   %esi
80101344:	53                   	push   %ebx
80101345:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101348:	83 ec 08             	sub    $0x8,%esp
8010134b:	6a 01                	push   $0x1
8010134d:	ff 75 08             	pushl  0x8(%ebp)
80101350:	e8 5f ed ff ff       	call   801000b4 <bread>
80101355:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
80101357:	83 c4 0c             	add    $0xc,%esp
8010135a:	6a 1c                	push   $0x1c
8010135c:	8d 40 5c             	lea    0x5c(%eax),%eax
8010135f:	50                   	push   %eax
80101360:	56                   	push   %esi
80101361:	e8 4a 2e 00 00       	call   801041b0 <memmove>
  brelse(bp);
80101366:	83 c4 10             	add    $0x10,%esp
80101369:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010136c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010136f:	5b                   	pop    %ebx
80101370:	5e                   	pop    %esi
80101371:	5d                   	pop    %ebp
  brelse(bp);
80101372:	e9 49 ee ff ff       	jmp    801001c0 <brelse>
80101377:	90                   	nop

80101378 <iinit>:
{
80101378:	55                   	push   %ebp
80101379:	89 e5                	mov    %esp,%ebp
8010137b:	53                   	push   %ebx
8010137c:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010137f:	68 ab 68 10 80       	push   $0x801068ab
80101384:	68 c0 13 11 80       	push   $0x801113c0
80101389:	e8 7e 2b 00 00       	call   80103f0c <initlock>
  for(i = 0; i < NINODE; i++) {
8010138e:	bb 00 14 11 80       	mov    $0x80111400,%ebx
80101393:	83 c4 10             	add    $0x10,%esp
80101396:	66 90                	xchg   %ax,%ax
    initsleeplock(&icache.inode[i].lock, "inode");
80101398:	83 ec 08             	sub    $0x8,%esp
8010139b:	68 b2 68 10 80       	push   $0x801068b2
801013a0:	53                   	push   %ebx
801013a1:	e8 56 2a 00 00       	call   80103dfc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801013a6:	81 c3 90 00 00 00    	add    $0x90,%ebx
801013ac:	83 c4 10             	add    $0x10,%esp
801013af:	81 fb 20 30 11 80    	cmp    $0x80113020,%ebx
801013b5:	75 e1                	jne    80101398 <iinit+0x20>
  readsb(dev, &sb);
801013b7:	83 ec 08             	sub    $0x8,%esp
801013ba:	68 a0 13 11 80       	push   $0x801113a0
801013bf:	ff 75 08             	pushl  0x8(%ebp)
801013c2:	e8 79 ff ff ff       	call   80101340 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801013c7:	ff 35 b8 13 11 80    	pushl  0x801113b8
801013cd:	ff 35 b4 13 11 80    	pushl  0x801113b4
801013d3:	ff 35 b0 13 11 80    	pushl  0x801113b0
801013d9:	ff 35 ac 13 11 80    	pushl  0x801113ac
801013df:	ff 35 a8 13 11 80    	pushl  0x801113a8
801013e5:	ff 35 a4 13 11 80    	pushl  0x801113a4
801013eb:	ff 35 a0 13 11 80    	pushl  0x801113a0
801013f1:	68 18 69 10 80       	push   $0x80106918
801013f6:	e8 25 f2 ff ff       	call   80100620 <cprintf>
}
801013fb:	83 c4 30             	add    $0x30,%esp
801013fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101401:	c9                   	leave  
80101402:	c3                   	ret    
80101403:	90                   	nop

80101404 <ialloc>:
{
80101404:	55                   	push   %ebp
80101405:	89 e5                	mov    %esp,%ebp
80101407:	57                   	push   %edi
80101408:	56                   	push   %esi
80101409:	53                   	push   %ebx
8010140a:	83 ec 1c             	sub    $0x1c,%esp
8010140d:	8b 75 08             	mov    0x8(%ebp),%esi
80101410:	8b 45 0c             	mov    0xc(%ebp),%eax
80101413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101416:	83 3d a8 13 11 80 01 	cmpl   $0x1,0x801113a8
8010141d:	0f 86 84 00 00 00    	jbe    801014a7 <ialloc+0xa3>
80101423:	bf 01 00 00 00       	mov    $0x1,%edi
80101428:	eb 17                	jmp    80101441 <ialloc+0x3d>
8010142a:	66 90                	xchg   %ax,%ax
    brelse(bp);
8010142c:	83 ec 0c             	sub    $0xc,%esp
8010142f:	53                   	push   %ebx
80101430:	e8 8b ed ff ff       	call   801001c0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
80101435:	47                   	inc    %edi
80101436:	83 c4 10             	add    $0x10,%esp
80101439:	3b 3d a8 13 11 80    	cmp    0x801113a8,%edi
8010143f:	73 66                	jae    801014a7 <ialloc+0xa3>
    bp = bread(dev, IBLOCK(inum, sb));
80101441:	83 ec 08             	sub    $0x8,%esp
80101444:	89 f8                	mov    %edi,%eax
80101446:	c1 e8 03             	shr    $0x3,%eax
80101449:	03 05 b4 13 11 80    	add    0x801113b4,%eax
8010144f:	50                   	push   %eax
80101450:	56                   	push   %esi
80101451:	e8 5e ec ff ff       	call   801000b4 <bread>
80101456:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
80101458:	89 f8                	mov    %edi,%eax
8010145a:	83 e0 07             	and    $0x7,%eax
8010145d:	c1 e0 06             	shl    $0x6,%eax
80101460:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
80101464:	83 c4 10             	add    $0x10,%esp
80101467:	66 83 39 00          	cmpw   $0x0,(%ecx)
8010146b:	75 bf                	jne    8010142c <ialloc+0x28>
      memset(dip, 0, sizeof(*dip));
8010146d:	50                   	push   %eax
8010146e:	6a 40                	push   $0x40
80101470:	6a 00                	push   $0x0
80101472:	51                   	push   %ecx
80101473:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101476:	e8 b1 2c 00 00       	call   8010412c <memset>
      dip->type = type;
8010147b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010147e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80101481:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
80101484:	89 1c 24             	mov    %ebx,(%esp)
80101487:	e8 6c 15 00 00       	call   801029f8 <log_write>
      brelse(bp);
8010148c:	89 1c 24             	mov    %ebx,(%esp)
8010148f:	e8 2c ed ff ff       	call   801001c0 <brelse>
      return iget(dev, inum);
80101494:	83 c4 10             	add    $0x10,%esp
80101497:	89 fa                	mov    %edi,%edx
80101499:	89 f0                	mov    %esi,%eax
}
8010149b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010149e:	5b                   	pop    %ebx
8010149f:	5e                   	pop    %esi
801014a0:	5f                   	pop    %edi
801014a1:	5d                   	pop    %ebp
      return iget(dev, inum);
801014a2:	e9 01 fd ff ff       	jmp    801011a8 <iget>
  panic("ialloc: no inodes");
801014a7:	83 ec 0c             	sub    $0xc,%esp
801014aa:	68 b8 68 10 80       	push   $0x801068b8
801014af:	e8 8c ee ff ff       	call   80100340 <panic>

801014b4 <iupdate>:
{
801014b4:	55                   	push   %ebp
801014b5:	89 e5                	mov    %esp,%ebp
801014b7:	56                   	push   %esi
801014b8:	53                   	push   %ebx
801014b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801014bc:	83 ec 08             	sub    $0x8,%esp
801014bf:	8b 43 04             	mov    0x4(%ebx),%eax
801014c2:	c1 e8 03             	shr    $0x3,%eax
801014c5:	03 05 b4 13 11 80    	add    0x801113b4,%eax
801014cb:	50                   	push   %eax
801014cc:	ff 33                	pushl  (%ebx)
801014ce:	e8 e1 eb ff ff       	call   801000b4 <bread>
801014d3:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801014d5:	8b 43 04             	mov    0x4(%ebx),%eax
801014d8:	83 e0 07             	and    $0x7,%eax
801014db:	c1 e0 06             	shl    $0x6,%eax
801014de:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
801014e2:	8b 53 50             	mov    0x50(%ebx),%edx
801014e5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801014e8:	66 8b 53 52          	mov    0x52(%ebx),%dx
801014ec:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801014f0:	8b 53 54             	mov    0x54(%ebx),%edx
801014f3:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801014f7:	66 8b 53 56          	mov    0x56(%ebx),%dx
801014fb:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801014ff:	8b 53 58             	mov    0x58(%ebx),%edx
80101502:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101505:	83 c4 0c             	add    $0xc,%esp
80101508:	6a 34                	push   $0x34
8010150a:	83 c3 5c             	add    $0x5c,%ebx
8010150d:	53                   	push   %ebx
8010150e:	83 c0 0c             	add    $0xc,%eax
80101511:	50                   	push   %eax
80101512:	e8 99 2c 00 00       	call   801041b0 <memmove>
  log_write(bp);
80101517:	89 34 24             	mov    %esi,(%esp)
8010151a:	e8 d9 14 00 00       	call   801029f8 <log_write>
  brelse(bp);
8010151f:	83 c4 10             	add    $0x10,%esp
80101522:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101525:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101528:	5b                   	pop    %ebx
80101529:	5e                   	pop    %esi
8010152a:	5d                   	pop    %ebp
  brelse(bp);
8010152b:	e9 90 ec ff ff       	jmp    801001c0 <brelse>

80101530 <idup>:
{
80101530:	55                   	push   %ebp
80101531:	89 e5                	mov    %esp,%ebp
80101533:	53                   	push   %ebx
80101534:	83 ec 10             	sub    $0x10,%esp
80101537:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010153a:	68 c0 13 11 80       	push   $0x801113c0
8010153f:	e8 08 2b 00 00       	call   8010404c <acquire>
  ip->ref++;
80101544:	ff 43 08             	incl   0x8(%ebx)
  release(&icache.lock);
80101547:	c7 04 24 c0 13 11 80 	movl   $0x801113c0,(%esp)
8010154e:	e8 91 2b 00 00       	call   801040e4 <release>
}
80101553:	89 d8                	mov    %ebx,%eax
80101555:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101558:	c9                   	leave  
80101559:	c3                   	ret    
8010155a:	66 90                	xchg   %ax,%ax

8010155c <ilock>:
{
8010155c:	55                   	push   %ebp
8010155d:	89 e5                	mov    %esp,%ebp
8010155f:	56                   	push   %esi
80101560:	53                   	push   %ebx
80101561:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101564:	85 db                	test   %ebx,%ebx
80101566:	0f 84 a9 00 00 00    	je     80101615 <ilock+0xb9>
8010156c:	8b 53 08             	mov    0x8(%ebx),%edx
8010156f:	85 d2                	test   %edx,%edx
80101571:	0f 8e 9e 00 00 00    	jle    80101615 <ilock+0xb9>
  acquiresleep(&ip->lock);
80101577:	83 ec 0c             	sub    $0xc,%esp
8010157a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010157d:	50                   	push   %eax
8010157e:	e8 ad 28 00 00       	call   80103e30 <acquiresleep>
  if(ip->valid == 0){
80101583:	83 c4 10             	add    $0x10,%esp
80101586:	8b 43 4c             	mov    0x4c(%ebx),%eax
80101589:	85 c0                	test   %eax,%eax
8010158b:	74 07                	je     80101594 <ilock+0x38>
}
8010158d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101590:	5b                   	pop    %ebx
80101591:	5e                   	pop    %esi
80101592:	5d                   	pop    %ebp
80101593:	c3                   	ret    
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101594:	83 ec 08             	sub    $0x8,%esp
80101597:	8b 43 04             	mov    0x4(%ebx),%eax
8010159a:	c1 e8 03             	shr    $0x3,%eax
8010159d:	03 05 b4 13 11 80    	add    0x801113b4,%eax
801015a3:	50                   	push   %eax
801015a4:	ff 33                	pushl  (%ebx)
801015a6:	e8 09 eb ff ff       	call   801000b4 <bread>
801015ab:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015ad:	8b 43 04             	mov    0x4(%ebx),%eax
801015b0:	83 e0 07             	and    $0x7,%eax
801015b3:	c1 e0 06             	shl    $0x6,%eax
801015b6:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015ba:	8b 10                	mov    (%eax),%edx
801015bc:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015c0:	66 8b 50 02          	mov    0x2(%eax),%dx
801015c4:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801015c8:	8b 50 04             	mov    0x4(%eax),%edx
801015cb:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801015cf:	66 8b 50 06          	mov    0x6(%eax),%dx
801015d3:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
801015d7:	8b 50 08             	mov    0x8(%eax),%edx
801015da:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801015dd:	83 c4 0c             	add    $0xc,%esp
801015e0:	6a 34                	push   $0x34
801015e2:	83 c0 0c             	add    $0xc,%eax
801015e5:	50                   	push   %eax
801015e6:	8d 43 5c             	lea    0x5c(%ebx),%eax
801015e9:	50                   	push   %eax
801015ea:	e8 c1 2b 00 00       	call   801041b0 <memmove>
    brelse(bp);
801015ef:	89 34 24             	mov    %esi,(%esp)
801015f2:	e8 c9 eb ff ff       	call   801001c0 <brelse>
    ip->valid = 1;
801015f7:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
801015fe:	83 c4 10             	add    $0x10,%esp
80101601:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
80101606:	75 85                	jne    8010158d <ilock+0x31>
      panic("ilock: no type");
80101608:	83 ec 0c             	sub    $0xc,%esp
8010160b:	68 d0 68 10 80       	push   $0x801068d0
80101610:	e8 2b ed ff ff       	call   80100340 <panic>
    panic("ilock");
80101615:	83 ec 0c             	sub    $0xc,%esp
80101618:	68 ca 68 10 80       	push   $0x801068ca
8010161d:	e8 1e ed ff ff       	call   80100340 <panic>
80101622:	66 90                	xchg   %ax,%ax

80101624 <iunlock>:
{
80101624:	55                   	push   %ebp
80101625:	89 e5                	mov    %esp,%ebp
80101627:	56                   	push   %esi
80101628:	53                   	push   %ebx
80101629:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
8010162c:	85 db                	test   %ebx,%ebx
8010162e:	74 28                	je     80101658 <iunlock+0x34>
80101630:	8d 73 0c             	lea    0xc(%ebx),%esi
80101633:	83 ec 0c             	sub    $0xc,%esp
80101636:	56                   	push   %esi
80101637:	e8 84 28 00 00       	call   80103ec0 <holdingsleep>
8010163c:	83 c4 10             	add    $0x10,%esp
8010163f:	85 c0                	test   %eax,%eax
80101641:	74 15                	je     80101658 <iunlock+0x34>
80101643:	8b 43 08             	mov    0x8(%ebx),%eax
80101646:	85 c0                	test   %eax,%eax
80101648:	7e 0e                	jle    80101658 <iunlock+0x34>
  releasesleep(&ip->lock);
8010164a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010164d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101650:	5b                   	pop    %ebx
80101651:	5e                   	pop    %esi
80101652:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
80101653:	e9 2c 28 00 00       	jmp    80103e84 <releasesleep>
    panic("iunlock");
80101658:	83 ec 0c             	sub    $0xc,%esp
8010165b:	68 df 68 10 80       	push   $0x801068df
80101660:	e8 db ec ff ff       	call   80100340 <panic>
80101665:	8d 76 00             	lea    0x0(%esi),%esi

80101668 <iput>:
{
80101668:	55                   	push   %ebp
80101669:	89 e5                	mov    %esp,%ebp
8010166b:	57                   	push   %edi
8010166c:	56                   	push   %esi
8010166d:	53                   	push   %ebx
8010166e:	83 ec 28             	sub    $0x28,%esp
80101671:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101674:	8d 73 0c             	lea    0xc(%ebx),%esi
80101677:	56                   	push   %esi
80101678:	e8 b3 27 00 00       	call   80103e30 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010167d:	83 c4 10             	add    $0x10,%esp
80101680:	8b 43 4c             	mov    0x4c(%ebx),%eax
80101683:	85 c0                	test   %eax,%eax
80101685:	74 07                	je     8010168e <iput+0x26>
80101687:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010168c:	74 2e                	je     801016bc <iput+0x54>
  releasesleep(&ip->lock);
8010168e:	83 ec 0c             	sub    $0xc,%esp
80101691:	56                   	push   %esi
80101692:	e8 ed 27 00 00       	call   80103e84 <releasesleep>
  acquire(&icache.lock);
80101697:	c7 04 24 c0 13 11 80 	movl   $0x801113c0,(%esp)
8010169e:	e8 a9 29 00 00       	call   8010404c <acquire>
  ip->ref--;
801016a3:	ff 4b 08             	decl   0x8(%ebx)
  release(&icache.lock);
801016a6:	83 c4 10             	add    $0x10,%esp
801016a9:	c7 45 08 c0 13 11 80 	movl   $0x801113c0,0x8(%ebp)
}
801016b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016b3:	5b                   	pop    %ebx
801016b4:	5e                   	pop    %esi
801016b5:	5f                   	pop    %edi
801016b6:	5d                   	pop    %ebp
  release(&icache.lock);
801016b7:	e9 28 2a 00 00       	jmp    801040e4 <release>
    acquire(&icache.lock);
801016bc:	83 ec 0c             	sub    $0xc,%esp
801016bf:	68 c0 13 11 80       	push   $0x801113c0
801016c4:	e8 83 29 00 00       	call   8010404c <acquire>
    int r = ip->ref;
801016c9:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016cc:	c7 04 24 c0 13 11 80 	movl   $0x801113c0,(%esp)
801016d3:	e8 0c 2a 00 00       	call   801040e4 <release>
    if(r == 1){
801016d8:	83 c4 10             	add    $0x10,%esp
801016db:	4f                   	dec    %edi
801016dc:	75 b0                	jne    8010168e <iput+0x26>
801016de:	8d 7b 5c             	lea    0x5c(%ebx),%edi
801016e1:	8d 83 8c 00 00 00    	lea    0x8c(%ebx),%eax
801016e7:	89 75 e4             	mov    %esi,-0x1c(%ebp)
801016ea:	89 fe                	mov    %edi,%esi
801016ec:	89 c7                	mov    %eax,%edi
801016ee:	eb 07                	jmp    801016f7 <iput+0x8f>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801016f0:	83 c6 04             	add    $0x4,%esi
801016f3:	39 fe                	cmp    %edi,%esi
801016f5:	74 15                	je     8010170c <iput+0xa4>
    if(ip->addrs[i]){
801016f7:	8b 16                	mov    (%esi),%edx
801016f9:	85 d2                	test   %edx,%edx
801016fb:	74 f3                	je     801016f0 <iput+0x88>
      bfree(ip->dev, ip->addrs[i]);
801016fd:	8b 03                	mov    (%ebx),%eax
801016ff:	e8 38 f9 ff ff       	call   8010103c <bfree>
      ip->addrs[i] = 0;
80101704:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010170a:	eb e4                	jmp    801016f0 <iput+0x88>
8010170c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
8010170f:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101715:	85 c0                	test   %eax,%eax
80101717:	75 2f                	jne    80101748 <iput+0xe0>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
80101719:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101720:	83 ec 0c             	sub    $0xc,%esp
80101723:	53                   	push   %ebx
80101724:	e8 8b fd ff ff       	call   801014b4 <iupdate>
      ip->type = 0;
80101729:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
8010172f:	89 1c 24             	mov    %ebx,(%esp)
80101732:	e8 7d fd ff ff       	call   801014b4 <iupdate>
      ip->valid = 0;
80101737:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
8010173e:	83 c4 10             	add    $0x10,%esp
80101741:	e9 48 ff ff ff       	jmp    8010168e <iput+0x26>
80101746:	66 90                	xchg   %ax,%ax
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101748:	83 ec 08             	sub    $0x8,%esp
8010174b:	50                   	push   %eax
8010174c:	ff 33                	pushl  (%ebx)
8010174e:	e8 61 e9 ff ff       	call   801000b4 <bread>
80101753:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101756:	8d 78 5c             	lea    0x5c(%eax),%edi
80101759:	05 5c 02 00 00       	add    $0x25c,%eax
8010175e:	83 c4 10             	add    $0x10,%esp
80101761:	89 75 e0             	mov    %esi,-0x20(%ebp)
80101764:	89 fe                	mov    %edi,%esi
80101766:	89 c7                	mov    %eax,%edi
80101768:	eb 09                	jmp    80101773 <iput+0x10b>
8010176a:	66 90                	xchg   %ax,%ax
8010176c:	83 c6 04             	add    $0x4,%esi
8010176f:	39 f7                	cmp    %esi,%edi
80101771:	74 11                	je     80101784 <iput+0x11c>
      if(a[j])
80101773:	8b 16                	mov    (%esi),%edx
80101775:	85 d2                	test   %edx,%edx
80101777:	74 f3                	je     8010176c <iput+0x104>
        bfree(ip->dev, a[j]);
80101779:	8b 03                	mov    (%ebx),%eax
8010177b:	e8 bc f8 ff ff       	call   8010103c <bfree>
80101780:	eb ea                	jmp    8010176c <iput+0x104>
80101782:	66 90                	xchg   %ax,%ax
80101784:	8b 75 e0             	mov    -0x20(%ebp),%esi
    brelse(bp);
80101787:	83 ec 0c             	sub    $0xc,%esp
8010178a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010178d:	e8 2e ea ff ff       	call   801001c0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101792:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101798:	8b 03                	mov    (%ebx),%eax
8010179a:	e8 9d f8 ff ff       	call   8010103c <bfree>
    ip->addrs[NDIRECT] = 0;
8010179f:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
801017a6:	00 00 00 
801017a9:	83 c4 10             	add    $0x10,%esp
801017ac:	e9 68 ff ff ff       	jmp    80101719 <iput+0xb1>
801017b1:	8d 76 00             	lea    0x0(%esi),%esi

801017b4 <iunlockput>:
{
801017b4:	55                   	push   %ebp
801017b5:	89 e5                	mov    %esp,%ebp
801017b7:	53                   	push   %ebx
801017b8:	83 ec 10             	sub    $0x10,%esp
801017bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
801017be:	53                   	push   %ebx
801017bf:	e8 60 fe ff ff       	call   80101624 <iunlock>
  iput(ip);
801017c4:	83 c4 10             	add    $0x10,%esp
801017c7:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801017ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801017cd:	c9                   	leave  
  iput(ip);
801017ce:	e9 95 fe ff ff       	jmp    80101668 <iput>
801017d3:	90                   	nop

801017d4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
801017d4:	55                   	push   %ebp
801017d5:	89 e5                	mov    %esp,%ebp
801017d7:	8b 55 08             	mov    0x8(%ebp),%edx
801017da:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
801017dd:	8b 0a                	mov    (%edx),%ecx
801017df:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
801017e2:	8b 4a 04             	mov    0x4(%edx),%ecx
801017e5:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
801017e8:	8b 4a 50             	mov    0x50(%edx),%ecx
801017eb:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
801017ee:	66 8b 4a 56          	mov    0x56(%edx),%cx
801017f2:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
801017f6:	8b 52 58             	mov    0x58(%edx),%edx
801017f9:	89 50 10             	mov    %edx,0x10(%eax)
}
801017fc:	5d                   	pop    %ebp
801017fd:	c3                   	ret    
801017fe:	66 90                	xchg   %ax,%ax

80101800 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101800:	55                   	push   %ebp
80101801:	89 e5                	mov    %esp,%ebp
80101803:	57                   	push   %edi
80101804:	56                   	push   %esi
80101805:	53                   	push   %ebx
80101806:	83 ec 1c             	sub    $0x1c,%esp
80101809:	8b 7d 08             	mov    0x8(%ebp),%edi
8010180c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010180f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80101812:	8b 45 10             	mov    0x10(%ebp),%eax
80101815:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101818:	8b 45 14             	mov    0x14(%ebp),%eax
8010181b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010181e:	66 83 7f 50 03       	cmpw   $0x3,0x50(%edi)
80101823:	0f 84 a3 00 00 00    	je     801018cc <readi+0xcc>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101829:	8b 47 58             	mov    0x58(%edi),%eax
8010182c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
8010182f:	39 c3                	cmp    %eax,%ebx
80101831:	0f 87 b9 00 00 00    	ja     801018f0 <readi+0xf0>
80101837:	89 da                	mov    %ebx,%edx
80101839:	31 c9                	xor    %ecx,%ecx
8010183b:	03 55 e4             	add    -0x1c(%ebp),%edx
8010183e:	0f 92 c1             	setb   %cl
80101841:	89 ce                	mov    %ecx,%esi
80101843:	0f 82 a7 00 00 00    	jb     801018f0 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
80101849:	39 d0                	cmp    %edx,%eax
8010184b:	72 77                	jb     801018c4 <readi+0xc4>
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010184d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101850:	85 db                	test   %ebx,%ebx
80101852:	74 65                	je     801018b9 <readi+0xb9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101854:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101857:	89 da                	mov    %ebx,%edx
80101859:	c1 ea 09             	shr    $0x9,%edx
8010185c:	89 f8                	mov    %edi,%eax
8010185e:	e8 1d fa ff ff       	call   80101280 <bmap>
80101863:	83 ec 08             	sub    $0x8,%esp
80101866:	50                   	push   %eax
80101867:	ff 37                	pushl  (%edi)
80101869:	e8 46 e8 ff ff       	call   801000b4 <bread>
8010186e:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101870:	89 d8                	mov    %ebx,%eax
80101872:	25 ff 01 00 00       	and    $0x1ff,%eax
80101877:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010187a:	29 f1                	sub    %esi,%ecx
8010187c:	bb 00 02 00 00       	mov    $0x200,%ebx
80101881:	29 c3                	sub    %eax,%ebx
80101883:	83 c4 10             	add    $0x10,%esp
80101886:	39 cb                	cmp    %ecx,%ebx
80101888:	76 02                	jbe    8010188c <readi+0x8c>
8010188a:	89 cb                	mov    %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
8010188c:	51                   	push   %ecx
8010188d:	53                   	push   %ebx
8010188e:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
80101892:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101895:	50                   	push   %eax
80101896:	ff 75 dc             	pushl  -0x24(%ebp)
80101899:	e8 12 29 00 00       	call   801041b0 <memmove>
    brelse(bp);
8010189e:	8b 55 d8             	mov    -0x28(%ebp),%edx
801018a1:	89 14 24             	mov    %edx,(%esp)
801018a4:	e8 17 e9 ff ff       	call   801001c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801018a9:	01 de                	add    %ebx,%esi
801018ab:	01 5d e0             	add    %ebx,-0x20(%ebp)
801018ae:	01 5d dc             	add    %ebx,-0x24(%ebp)
801018b1:	83 c4 10             	add    $0x10,%esp
801018b4:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
801018b7:	77 9b                	ja     80101854 <readi+0x54>
  }
  return n;
801018b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
801018bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801018bf:	5b                   	pop    %ebx
801018c0:	5e                   	pop    %esi
801018c1:	5f                   	pop    %edi
801018c2:	5d                   	pop    %ebp
801018c3:	c3                   	ret    
    n = ip->size - off;
801018c4:	29 d8                	sub    %ebx,%eax
801018c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801018c9:	eb 82                	jmp    8010184d <readi+0x4d>
801018cb:	90                   	nop
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801018cc:	0f bf 47 52          	movswl 0x52(%edi),%eax
801018d0:	66 83 f8 09          	cmp    $0x9,%ax
801018d4:	77 1a                	ja     801018f0 <readi+0xf0>
801018d6:	8b 04 c5 40 13 11 80 	mov    -0x7feeecc0(,%eax,8),%eax
801018dd:	85 c0                	test   %eax,%eax
801018df:	74 0f                	je     801018f0 <readi+0xf0>
    return devsw[ip->major].read(ip, dst, n);
801018e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801018e4:	89 7d 10             	mov    %edi,0x10(%ebp)
}
801018e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801018ea:	5b                   	pop    %ebx
801018eb:	5e                   	pop    %esi
801018ec:	5f                   	pop    %edi
801018ed:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
801018ee:	ff e0                	jmp    *%eax
      return -1;
801018f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018f5:	eb c5                	jmp    801018bc <readi+0xbc>
801018f7:	90                   	nop

801018f8 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801018f8:	55                   	push   %ebp
801018f9:	89 e5                	mov    %esp,%ebp
801018fb:	57                   	push   %edi
801018fc:	56                   	push   %esi
801018fd:	53                   	push   %ebx
801018fe:	83 ec 1c             	sub    $0x1c,%esp
80101901:	8b 45 08             	mov    0x8(%ebp),%eax
80101904:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101907:	8b 75 0c             	mov    0xc(%ebp),%esi
8010190a:	89 75 dc             	mov    %esi,-0x24(%ebp)
8010190d:	8b 75 10             	mov    0x10(%ebp),%esi
80101910:	89 75 e0             	mov    %esi,-0x20(%ebp)
80101913:	8b 75 14             	mov    0x14(%ebp),%esi
80101916:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101919:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010191e:	0f 84 b0 00 00 00    	je     801019d4 <writei+0xdc>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101924:	8b 75 d8             	mov    -0x28(%ebp),%esi
80101927:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010192a:	39 46 58             	cmp    %eax,0x58(%esi)
8010192d:	0f 82 dc 00 00 00    	jb     80101a0f <writei+0x117>
80101933:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101936:	31 c9                	xor    %ecx,%ecx
80101938:	01 d0                	add    %edx,%eax
8010193a:	0f 92 c1             	setb   %cl
8010193d:	89 ce                	mov    %ecx,%esi
8010193f:	0f 82 ca 00 00 00    	jb     80101a0f <writei+0x117>
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101945:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010194a:	0f 87 bf 00 00 00    	ja     80101a0f <writei+0x117>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101950:	85 d2                	test   %edx,%edx
80101952:	74 75                	je     801019c9 <writei+0xd1>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101954:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101957:	89 da                	mov    %ebx,%edx
80101959:	c1 ea 09             	shr    $0x9,%edx
8010195c:	8b 7d d8             	mov    -0x28(%ebp),%edi
8010195f:	89 f8                	mov    %edi,%eax
80101961:	e8 1a f9 ff ff       	call   80101280 <bmap>
80101966:	83 ec 08             	sub    $0x8,%esp
80101969:	50                   	push   %eax
8010196a:	ff 37                	pushl  (%edi)
8010196c:	e8 43 e7 ff ff       	call   801000b4 <bread>
80101971:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101973:	89 d8                	mov    %ebx,%eax
80101975:	25 ff 01 00 00       	and    $0x1ff,%eax
8010197a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010197d:	29 f1                	sub    %esi,%ecx
8010197f:	bb 00 02 00 00       	mov    $0x200,%ebx
80101984:	29 c3                	sub    %eax,%ebx
80101986:	83 c4 10             	add    $0x10,%esp
80101989:	39 cb                	cmp    %ecx,%ebx
8010198b:	76 02                	jbe    8010198f <writei+0x97>
8010198d:	89 cb                	mov    %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
8010198f:	52                   	push   %edx
80101990:	53                   	push   %ebx
80101991:	ff 75 dc             	pushl  -0x24(%ebp)
80101994:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101998:	50                   	push   %eax
80101999:	e8 12 28 00 00       	call   801041b0 <memmove>
    log_write(bp);
8010199e:	89 3c 24             	mov    %edi,(%esp)
801019a1:	e8 52 10 00 00       	call   801029f8 <log_write>
    brelse(bp);
801019a6:	89 3c 24             	mov    %edi,(%esp)
801019a9:	e8 12 e8 ff ff       	call   801001c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801019ae:	01 de                	add    %ebx,%esi
801019b0:	01 5d e0             	add    %ebx,-0x20(%ebp)
801019b3:	01 5d dc             	add    %ebx,-0x24(%ebp)
801019b6:	83 c4 10             	add    $0x10,%esp
801019b9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
801019bc:	77 96                	ja     80101954 <writei+0x5c>
  }

  if(n > 0 && off > ip->size){
801019be:	8b 45 d8             	mov    -0x28(%ebp),%eax
801019c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
801019c4:	3b 70 58             	cmp    0x58(%eax),%esi
801019c7:	77 2f                	ja     801019f8 <writei+0x100>
    ip->size = off;
    iupdate(ip);
  }
  return n;
801019c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
801019cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019cf:	5b                   	pop    %ebx
801019d0:	5e                   	pop    %esi
801019d1:	5f                   	pop    %edi
801019d2:	5d                   	pop    %ebp
801019d3:	c3                   	ret    
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801019d4:	0f bf 40 52          	movswl 0x52(%eax),%eax
801019d8:	66 83 f8 09          	cmp    $0x9,%ax
801019dc:	77 31                	ja     80101a0f <writei+0x117>
801019de:	8b 04 c5 44 13 11 80 	mov    -0x7feeecbc(,%eax,8),%eax
801019e5:	85 c0                	test   %eax,%eax
801019e7:	74 26                	je     80101a0f <writei+0x117>
    return devsw[ip->major].write(ip, src, n);
801019e9:	89 75 10             	mov    %esi,0x10(%ebp)
}
801019ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019ef:	5b                   	pop    %ebx
801019f0:	5e                   	pop    %esi
801019f1:	5f                   	pop    %edi
801019f2:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
801019f3:	ff e0                	jmp    *%eax
801019f5:	8d 76 00             	lea    0x0(%esi),%esi
    ip->size = off;
801019f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801019fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
801019fe:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101a01:	83 ec 0c             	sub    $0xc,%esp
80101a04:	50                   	push   %eax
80101a05:	e8 aa fa ff ff       	call   801014b4 <iupdate>
80101a0a:	83 c4 10             	add    $0x10,%esp
80101a0d:	eb ba                	jmp    801019c9 <writei+0xd1>
      return -1;
80101a0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101a14:	eb b6                	jmp    801019cc <writei+0xd4>
80101a16:	66 90                	xchg   %ax,%ax

80101a18 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101a18:	55                   	push   %ebp
80101a19:	89 e5                	mov    %esp,%ebp
80101a1b:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101a1e:	6a 0e                	push   $0xe
80101a20:	ff 75 0c             	pushl  0xc(%ebp)
80101a23:	ff 75 08             	pushl  0x8(%ebp)
80101a26:	e8 d5 27 00 00       	call   80104200 <strncmp>
}
80101a2b:	c9                   	leave  
80101a2c:	c3                   	ret    
80101a2d:	8d 76 00             	lea    0x0(%esi),%esi

80101a30 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101a30:	55                   	push   %ebp
80101a31:	89 e5                	mov    %esp,%ebp
80101a33:	57                   	push   %edi
80101a34:	56                   	push   %esi
80101a35:	53                   	push   %ebx
80101a36:	83 ec 1c             	sub    $0x1c,%esp
80101a39:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101a3c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101a41:	75 7d                	jne    80101ac0 <dirlookup+0x90>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101a43:	8b 4b 58             	mov    0x58(%ebx),%ecx
80101a46:	85 c9                	test   %ecx,%ecx
80101a48:	74 3d                	je     80101a87 <dirlookup+0x57>
80101a4a:	31 ff                	xor    %edi,%edi
80101a4c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101a4f:	90                   	nop
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101a50:	6a 10                	push   $0x10
80101a52:	57                   	push   %edi
80101a53:	56                   	push   %esi
80101a54:	53                   	push   %ebx
80101a55:	e8 a6 fd ff ff       	call   80101800 <readi>
80101a5a:	83 c4 10             	add    $0x10,%esp
80101a5d:	83 f8 10             	cmp    $0x10,%eax
80101a60:	75 51                	jne    80101ab3 <dirlookup+0x83>
      panic("dirlookup read");
    if(de.inum == 0)
80101a62:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a67:	74 16                	je     80101a7f <dirlookup+0x4f>
  return strncmp(s, t, DIRSIZ);
80101a69:	52                   	push   %edx
80101a6a:	6a 0e                	push   $0xe
80101a6c:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a6f:	50                   	push   %eax
80101a70:	ff 75 0c             	pushl  0xc(%ebp)
80101a73:	e8 88 27 00 00       	call   80104200 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101a78:	83 c4 10             	add    $0x10,%esp
80101a7b:	85 c0                	test   %eax,%eax
80101a7d:	74 15                	je     80101a94 <dirlookup+0x64>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101a7f:	83 c7 10             	add    $0x10,%edi
80101a82:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101a85:	72 c9                	jb     80101a50 <dirlookup+0x20>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80101a87:	31 c0                	xor    %eax,%eax
}
80101a89:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a8c:	5b                   	pop    %ebx
80101a8d:	5e                   	pop    %esi
80101a8e:	5f                   	pop    %edi
80101a8f:	5d                   	pop    %ebp
80101a90:	c3                   	ret    
80101a91:	8d 76 00             	lea    0x0(%esi),%esi
      if(poff)
80101a94:	8b 45 10             	mov    0x10(%ebp),%eax
80101a97:	85 c0                	test   %eax,%eax
80101a99:	74 05                	je     80101aa0 <dirlookup+0x70>
        *poff = off;
80101a9b:	8b 45 10             	mov    0x10(%ebp),%eax
80101a9e:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101aa0:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101aa4:	8b 03                	mov    (%ebx),%eax
80101aa6:	e8 fd f6 ff ff       	call   801011a8 <iget>
}
80101aab:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101aae:	5b                   	pop    %ebx
80101aaf:	5e                   	pop    %esi
80101ab0:	5f                   	pop    %edi
80101ab1:	5d                   	pop    %ebp
80101ab2:	c3                   	ret    
      panic("dirlookup read");
80101ab3:	83 ec 0c             	sub    $0xc,%esp
80101ab6:	68 f9 68 10 80       	push   $0x801068f9
80101abb:	e8 80 e8 ff ff       	call   80100340 <panic>
    panic("dirlookup not DIR");
80101ac0:	83 ec 0c             	sub    $0xc,%esp
80101ac3:	68 e7 68 10 80       	push   $0x801068e7
80101ac8:	e8 73 e8 ff ff       	call   80100340 <panic>
80101acd:	8d 76 00             	lea    0x0(%esi),%esi

80101ad0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101ad0:	55                   	push   %ebp
80101ad1:	89 e5                	mov    %esp,%ebp
80101ad3:	57                   	push   %edi
80101ad4:	56                   	push   %esi
80101ad5:	53                   	push   %ebx
80101ad6:	83 ec 1c             	sub    $0x1c,%esp
80101ad9:	89 c3                	mov    %eax,%ebx
80101adb:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ade:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101ae1:	80 38 2f             	cmpb   $0x2f,(%eax)
80101ae4:	0f 84 36 01 00 00    	je     80101c20 <namex+0x150>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101aea:	e8 71 18 00 00       	call   80103360 <myproc>
80101aef:	8b 70 68             	mov    0x68(%eax),%esi
  acquire(&icache.lock);
80101af2:	83 ec 0c             	sub    $0xc,%esp
80101af5:	68 c0 13 11 80       	push   $0x801113c0
80101afa:	e8 4d 25 00 00       	call   8010404c <acquire>
  ip->ref++;
80101aff:	ff 46 08             	incl   0x8(%esi)
  release(&icache.lock);
80101b02:	c7 04 24 c0 13 11 80 	movl   $0x801113c0,(%esp)
80101b09:	e8 d6 25 00 00       	call   801040e4 <release>
80101b0e:	83 c4 10             	add    $0x10,%esp
80101b11:	89 df                	mov    %ebx,%edi
80101b13:	eb 04                	jmp    80101b19 <namex+0x49>
80101b15:	8d 76 00             	lea    0x0(%esi),%esi
    path++;
80101b18:	47                   	inc    %edi
  while(*path == '/')
80101b19:	8a 07                	mov    (%edi),%al
80101b1b:	3c 2f                	cmp    $0x2f,%al
80101b1d:	74 f9                	je     80101b18 <namex+0x48>
  if(*path == 0)
80101b1f:	84 c0                	test   %al,%al
80101b21:	0f 84 b9 00 00 00    	je     80101be0 <namex+0x110>
  while(*path != '/' && *path != 0)
80101b27:	8a 07                	mov    (%edi),%al
80101b29:	89 fb                	mov    %edi,%ebx
80101b2b:	3c 2f                	cmp    $0x2f,%al
80101b2d:	75 0c                	jne    80101b3b <namex+0x6b>
80101b2f:	e9 e0 00 00 00       	jmp    80101c14 <namex+0x144>
    path++;
80101b34:	43                   	inc    %ebx
  while(*path != '/' && *path != 0)
80101b35:	8a 03                	mov    (%ebx),%al
80101b37:	3c 2f                	cmp    $0x2f,%al
80101b39:	74 04                	je     80101b3f <namex+0x6f>
80101b3b:	84 c0                	test   %al,%al
80101b3d:	75 f5                	jne    80101b34 <namex+0x64>
  len = path - s;
80101b3f:	89 d8                	mov    %ebx,%eax
80101b41:	29 f8                	sub    %edi,%eax
  if(len >= DIRSIZ)
80101b43:	83 f8 0d             	cmp    $0xd,%eax
80101b46:	7e 74                	jle    80101bbc <namex+0xec>
    memmove(name, s, DIRSIZ);
80101b48:	51                   	push   %ecx
80101b49:	6a 0e                	push   $0xe
80101b4b:	57                   	push   %edi
80101b4c:	ff 75 e4             	pushl  -0x1c(%ebp)
80101b4f:	e8 5c 26 00 00       	call   801041b0 <memmove>
80101b54:	83 c4 10             	add    $0x10,%esp
80101b57:	89 df                	mov    %ebx,%edi
  while(*path == '/')
80101b59:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101b5c:	75 08                	jne    80101b66 <namex+0x96>
80101b5e:	66 90                	xchg   %ax,%ax
    path++;
80101b60:	47                   	inc    %edi
  while(*path == '/')
80101b61:	80 3f 2f             	cmpb   $0x2f,(%edi)
80101b64:	74 fa                	je     80101b60 <namex+0x90>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101b66:	83 ec 0c             	sub    $0xc,%esp
80101b69:	56                   	push   %esi
80101b6a:	e8 ed f9 ff ff       	call   8010155c <ilock>
    if(ip->type != T_DIR){
80101b6f:	83 c4 10             	add    $0x10,%esp
80101b72:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101b77:	75 7b                	jne    80101bf4 <namex+0x124>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101b79:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101b7c:	85 c0                	test   %eax,%eax
80101b7e:	74 09                	je     80101b89 <namex+0xb9>
80101b80:	80 3f 00             	cmpb   $0x0,(%edi)
80101b83:	0f 84 af 00 00 00    	je     80101c38 <namex+0x168>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101b89:	50                   	push   %eax
80101b8a:	6a 00                	push   $0x0
80101b8c:	ff 75 e4             	pushl  -0x1c(%ebp)
80101b8f:	56                   	push   %esi
80101b90:	e8 9b fe ff ff       	call   80101a30 <dirlookup>
80101b95:	89 c3                	mov    %eax,%ebx
80101b97:	83 c4 10             	add    $0x10,%esp
80101b9a:	85 c0                	test   %eax,%eax
80101b9c:	74 56                	je     80101bf4 <namex+0x124>
  iunlock(ip);
80101b9e:	83 ec 0c             	sub    $0xc,%esp
80101ba1:	56                   	push   %esi
80101ba2:	e8 7d fa ff ff       	call   80101624 <iunlock>
  iput(ip);
80101ba7:	89 34 24             	mov    %esi,(%esp)
80101baa:	e8 b9 fa ff ff       	call   80101668 <iput>
80101baf:	83 c4 10             	add    $0x10,%esp
80101bb2:	89 de                	mov    %ebx,%esi
  while(*path == '/')
80101bb4:	e9 60 ff ff ff       	jmp    80101b19 <namex+0x49>
80101bb9:	8d 76 00             	lea    0x0(%esi),%esi
80101bbc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101bbf:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80101bc2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    memmove(name, s, len);
80101bc5:	52                   	push   %edx
80101bc6:	50                   	push   %eax
80101bc7:	57                   	push   %edi
80101bc8:	ff 75 e4             	pushl  -0x1c(%ebp)
80101bcb:	e8 e0 25 00 00       	call   801041b0 <memmove>
    name[len] = 0;
80101bd0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101bd3:	c6 00 00             	movb   $0x0,(%eax)
80101bd6:	83 c4 10             	add    $0x10,%esp
80101bd9:	89 df                	mov    %ebx,%edi
80101bdb:	e9 79 ff ff ff       	jmp    80101b59 <namex+0x89>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101be0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101be3:	85 db                	test   %ebx,%ebx
80101be5:	75 69                	jne    80101c50 <namex+0x180>
    iput(ip);
    return 0;
  }
  return ip;
}
80101be7:	89 f0                	mov    %esi,%eax
80101be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bec:	5b                   	pop    %ebx
80101bed:	5e                   	pop    %esi
80101bee:	5f                   	pop    %edi
80101bef:	5d                   	pop    %ebp
80101bf0:	c3                   	ret    
80101bf1:	8d 76 00             	lea    0x0(%esi),%esi
  iunlock(ip);
80101bf4:	83 ec 0c             	sub    $0xc,%esp
80101bf7:	56                   	push   %esi
80101bf8:	e8 27 fa ff ff       	call   80101624 <iunlock>
  iput(ip);
80101bfd:	89 34 24             	mov    %esi,(%esp)
80101c00:	e8 63 fa ff ff       	call   80101668 <iput>
      return 0;
80101c05:	83 c4 10             	add    $0x10,%esp
80101c08:	31 f6                	xor    %esi,%esi
}
80101c0a:	89 f0                	mov    %esi,%eax
80101c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c0f:	5b                   	pop    %ebx
80101c10:	5e                   	pop    %esi
80101c11:	5f                   	pop    %edi
80101c12:	5d                   	pop    %ebp
80101c13:	c3                   	ret    
  while(*path != '/' && *path != 0)
80101c14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c17:	89 45 dc             	mov    %eax,-0x24(%ebp)
80101c1a:	31 c0                	xor    %eax,%eax
80101c1c:	eb a7                	jmp    80101bc5 <namex+0xf5>
80101c1e:	66 90                	xchg   %ax,%ax
    ip = iget(ROOTDEV, ROOTINO);
80101c20:	ba 01 00 00 00       	mov    $0x1,%edx
80101c25:	b8 01 00 00 00       	mov    $0x1,%eax
80101c2a:	e8 79 f5 ff ff       	call   801011a8 <iget>
80101c2f:	89 c6                	mov    %eax,%esi
80101c31:	89 df                	mov    %ebx,%edi
80101c33:	e9 e1 fe ff ff       	jmp    80101b19 <namex+0x49>
      iunlock(ip);
80101c38:	83 ec 0c             	sub    $0xc,%esp
80101c3b:	56                   	push   %esi
80101c3c:	e8 e3 f9 ff ff       	call   80101624 <iunlock>
      return ip;
80101c41:	83 c4 10             	add    $0x10,%esp
}
80101c44:	89 f0                	mov    %esi,%eax
80101c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c49:	5b                   	pop    %ebx
80101c4a:	5e                   	pop    %esi
80101c4b:	5f                   	pop    %edi
80101c4c:	5d                   	pop    %ebp
80101c4d:	c3                   	ret    
80101c4e:	66 90                	xchg   %ax,%ax
    iput(ip);
80101c50:	83 ec 0c             	sub    $0xc,%esp
80101c53:	56                   	push   %esi
80101c54:	e8 0f fa ff ff       	call   80101668 <iput>
    return 0;
80101c59:	83 c4 10             	add    $0x10,%esp
80101c5c:	31 f6                	xor    %esi,%esi
80101c5e:	eb 87                	jmp    80101be7 <namex+0x117>

80101c60 <dirlink>:
{
80101c60:	55                   	push   %ebp
80101c61:	89 e5                	mov    %esp,%ebp
80101c63:	57                   	push   %edi
80101c64:	56                   	push   %esi
80101c65:	53                   	push   %ebx
80101c66:	83 ec 20             	sub    $0x20,%esp
80101c69:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
80101c6c:	6a 00                	push   $0x0
80101c6e:	ff 75 0c             	pushl  0xc(%ebp)
80101c71:	53                   	push   %ebx
80101c72:	e8 b9 fd ff ff       	call   80101a30 <dirlookup>
80101c77:	83 c4 10             	add    $0x10,%esp
80101c7a:	85 c0                	test   %eax,%eax
80101c7c:	75 65                	jne    80101ce3 <dirlink+0x83>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101c7e:	8b 7b 58             	mov    0x58(%ebx),%edi
80101c81:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101c84:	85 ff                	test   %edi,%edi
80101c86:	74 29                	je     80101cb1 <dirlink+0x51>
80101c88:	31 ff                	xor    %edi,%edi
80101c8a:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101c8d:	eb 09                	jmp    80101c98 <dirlink+0x38>
80101c8f:	90                   	nop
80101c90:	83 c7 10             	add    $0x10,%edi
80101c93:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101c96:	73 19                	jae    80101cb1 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101c98:	6a 10                	push   $0x10
80101c9a:	57                   	push   %edi
80101c9b:	56                   	push   %esi
80101c9c:	53                   	push   %ebx
80101c9d:	e8 5e fb ff ff       	call   80101800 <readi>
80101ca2:	83 c4 10             	add    $0x10,%esp
80101ca5:	83 f8 10             	cmp    $0x10,%eax
80101ca8:	75 4c                	jne    80101cf6 <dirlink+0x96>
    if(de.inum == 0)
80101caa:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101caf:	75 df                	jne    80101c90 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80101cb1:	50                   	push   %eax
80101cb2:	6a 0e                	push   $0xe
80101cb4:	ff 75 0c             	pushl  0xc(%ebp)
80101cb7:	8d 45 da             	lea    -0x26(%ebp),%eax
80101cba:	50                   	push   %eax
80101cbb:	e8 7c 25 00 00       	call   8010423c <strncpy>
  de.inum = inum;
80101cc0:	8b 45 10             	mov    0x10(%ebp),%eax
80101cc3:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101cc7:	6a 10                	push   $0x10
80101cc9:	57                   	push   %edi
80101cca:	56                   	push   %esi
80101ccb:	53                   	push   %ebx
80101ccc:	e8 27 fc ff ff       	call   801018f8 <writei>
80101cd1:	83 c4 20             	add    $0x20,%esp
80101cd4:	83 f8 10             	cmp    $0x10,%eax
80101cd7:	75 2a                	jne    80101d03 <dirlink+0xa3>
  return 0;
80101cd9:	31 c0                	xor    %eax,%eax
}
80101cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101cde:	5b                   	pop    %ebx
80101cdf:	5e                   	pop    %esi
80101ce0:	5f                   	pop    %edi
80101ce1:	5d                   	pop    %ebp
80101ce2:	c3                   	ret    
    iput(ip);
80101ce3:	83 ec 0c             	sub    $0xc,%esp
80101ce6:	50                   	push   %eax
80101ce7:	e8 7c f9 ff ff       	call   80101668 <iput>
    return -1;
80101cec:	83 c4 10             	add    $0x10,%esp
80101cef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101cf4:	eb e5                	jmp    80101cdb <dirlink+0x7b>
      panic("dirlink read");
80101cf6:	83 ec 0c             	sub    $0xc,%esp
80101cf9:	68 08 69 10 80       	push   $0x80106908
80101cfe:	e8 3d e6 ff ff       	call   80100340 <panic>
    panic("dirlink");
80101d03:	83 ec 0c             	sub    $0xc,%esp
80101d06:	68 02 6f 10 80       	push   $0x80106f02
80101d0b:	e8 30 e6 ff ff       	call   80100340 <panic>

80101d10 <namei>:

struct inode*
namei(char *path)
{
80101d10:	55                   	push   %ebp
80101d11:	89 e5                	mov    %esp,%ebp
80101d13:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101d16:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101d19:	31 d2                	xor    %edx,%edx
80101d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1e:	e8 ad fd ff ff       	call   80101ad0 <namex>
}
80101d23:	c9                   	leave  
80101d24:	c3                   	ret    
80101d25:	8d 76 00             	lea    0x0(%esi),%esi

80101d28 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101d28:	55                   	push   %ebp
80101d29:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
80101d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101d2e:	ba 01 00 00 00       	mov    $0x1,%edx
80101d33:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101d36:	5d                   	pop    %ebp
  return namex(path, 1, name);
80101d37:	e9 94 fd ff ff       	jmp    80101ad0 <namex>

80101d3c <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101d3c:	55                   	push   %ebp
80101d3d:	89 e5                	mov    %esp,%ebp
80101d3f:	57                   	push   %edi
80101d40:	56                   	push   %esi
80101d41:	53                   	push   %ebx
80101d42:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
80101d45:	85 c0                	test   %eax,%eax
80101d47:	0f 84 99 00 00 00    	je     80101de6 <idestart+0xaa>
80101d4d:	89 c3                	mov    %eax,%ebx
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101d4f:	8b 70 08             	mov    0x8(%eax),%esi
80101d52:	81 fe e7 03 00 00    	cmp    $0x3e7,%esi
80101d58:	77 7f                	ja     80101dd9 <idestart+0x9d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d5a:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80101d5f:	90                   	nop
80101d60:	89 ca                	mov    %ecx,%edx
80101d62:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101d63:	83 e0 c0             	and    $0xffffffc0,%eax
80101d66:	3c 40                	cmp    $0x40,%al
80101d68:	75 f6                	jne    80101d60 <idestart+0x24>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d6a:	31 ff                	xor    %edi,%edi
80101d6c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101d71:	89 f8                	mov    %edi,%eax
80101d73:	ee                   	out    %al,(%dx)
80101d74:	b0 01                	mov    $0x1,%al
80101d76:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101d7b:	ee                   	out    %al,(%dx)
80101d7c:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101d81:	89 f0                	mov    %esi,%eax
80101d83:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101d84:	89 f0                	mov    %esi,%eax
80101d86:	c1 f8 08             	sar    $0x8,%eax
80101d89:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101d8e:	ee                   	out    %al,(%dx)
80101d8f:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101d94:	89 f8                	mov    %edi,%eax
80101d96:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101d97:	8a 43 04             	mov    0x4(%ebx),%al
80101d9a:	c1 e0 04             	shl    $0x4,%eax
80101d9d:	83 e0 10             	and    $0x10,%eax
80101da0:	83 c8 e0             	or     $0xffffffe0,%eax
80101da3:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101da8:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101da9:	f6 03 04             	testb  $0x4,(%ebx)
80101dac:	75 0e                	jne    80101dbc <idestart+0x80>
80101dae:	b0 20                	mov    $0x20,%al
80101db0:	89 ca                	mov    %ecx,%edx
80101db2:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101db6:	5b                   	pop    %ebx
80101db7:	5e                   	pop    %esi
80101db8:	5f                   	pop    %edi
80101db9:	5d                   	pop    %ebp
80101dba:	c3                   	ret    
80101dbb:	90                   	nop
80101dbc:	b0 30                	mov    $0x30,%al
80101dbe:	89 ca                	mov    %ecx,%edx
80101dc0:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101dc1:	8d 73 5c             	lea    0x5c(%ebx),%esi
  asm volatile("cld; rep outsl" :
80101dc4:	b9 80 00 00 00       	mov    $0x80,%ecx
80101dc9:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101dce:	fc                   	cld    
80101dcf:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
80101dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101dd4:	5b                   	pop    %ebx
80101dd5:	5e                   	pop    %esi
80101dd6:	5f                   	pop    %edi
80101dd7:	5d                   	pop    %ebp
80101dd8:	c3                   	ret    
    panic("incorrect blockno");
80101dd9:	83 ec 0c             	sub    $0xc,%esp
80101ddc:	68 74 69 10 80       	push   $0x80106974
80101de1:	e8 5a e5 ff ff       	call   80100340 <panic>
    panic("idestart");
80101de6:	83 ec 0c             	sub    $0xc,%esp
80101de9:	68 6b 69 10 80       	push   $0x8010696b
80101dee:	e8 4d e5 ff ff       	call   80100340 <panic>
80101df3:	90                   	nop

80101df4 <ideinit>:
{
80101df4:	55                   	push   %ebp
80101df5:	89 e5                	mov    %esp,%ebp
80101df7:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101dfa:	68 86 69 10 80       	push   $0x80106986
80101dff:	68 80 a5 10 80       	push   $0x8010a580
80101e04:	e8 03 21 00 00       	call   80103f0c <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101e09:	58                   	pop    %eax
80101e0a:	5a                   	pop    %edx
80101e0b:	a1 e0 36 11 80       	mov    0x801136e0,%eax
80101e10:	48                   	dec    %eax
80101e11:	50                   	push   %eax
80101e12:	6a 0e                	push   $0xe
80101e14:	e8 57 02 00 00       	call   80102070 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101e19:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101e1c:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101e21:	8d 76 00             	lea    0x0(%esi),%esi
80101e24:	ec                   	in     (%dx),%al
80101e25:	83 e0 c0             	and    $0xffffffc0,%eax
80101e28:	3c 40                	cmp    $0x40,%al
80101e2a:	75 f8                	jne    80101e24 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101e2c:	b0 f0                	mov    $0xf0,%al
80101e2e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101e33:	ee                   	out    %al,(%dx)
80101e34:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101e39:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101e3e:	eb 03                	jmp    80101e43 <ideinit+0x4f>
  for(i=0; i<1000; i++){
80101e40:	49                   	dec    %ecx
80101e41:	74 0f                	je     80101e52 <ideinit+0x5e>
80101e43:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101e44:	84 c0                	test   %al,%al
80101e46:	74 f8                	je     80101e40 <ideinit+0x4c>
      havedisk1 = 1;
80101e48:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101e4f:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101e52:	b0 e0                	mov    $0xe0,%al
80101e54:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101e59:	ee                   	out    %al,(%dx)
}
80101e5a:	c9                   	leave  
80101e5b:	c3                   	ret    

80101e5c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101e5c:	55                   	push   %ebp
80101e5d:	89 e5                	mov    %esp,%ebp
80101e5f:	57                   	push   %edi
80101e60:	56                   	push   %esi
80101e61:	53                   	push   %ebx
80101e62:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101e65:	68 80 a5 10 80       	push   $0x8010a580
80101e6a:	e8 dd 21 00 00       	call   8010404c <acquire>

  if((b = idequeue) == 0){
80101e6f:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101e75:	83 c4 10             	add    $0x10,%esp
80101e78:	85 db                	test   %ebx,%ebx
80101e7a:	74 5b                	je     80101ed7 <ideintr+0x7b>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101e7c:	8b 43 58             	mov    0x58(%ebx),%eax
80101e7f:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101e84:	8b 33                	mov    (%ebx),%esi
80101e86:	f7 c6 04 00 00 00    	test   $0x4,%esi
80101e8c:	75 27                	jne    80101eb5 <ideintr+0x59>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101e8e:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101e93:	90                   	nop
80101e94:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101e95:	88 c1                	mov    %al,%cl
80101e97:	83 e1 c0             	and    $0xffffffc0,%ecx
80101e9a:	80 f9 40             	cmp    $0x40,%cl
80101e9d:	75 f5                	jne    80101e94 <ideintr+0x38>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101e9f:	a8 21                	test   $0x21,%al
80101ea1:	75 12                	jne    80101eb5 <ideintr+0x59>
    insl(0x1f0, b->data, BSIZE/4);
80101ea3:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101ea6:	b9 80 00 00 00       	mov    $0x80,%ecx
80101eab:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101eb0:	fc                   	cld    
80101eb1:	f3 6d                	rep insl (%dx),%es:(%edi)
80101eb3:	8b 33                	mov    (%ebx),%esi

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
80101eb5:	83 e6 fb             	and    $0xfffffffb,%esi
80101eb8:	83 ce 02             	or     $0x2,%esi
80101ebb:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
80101ebd:	83 ec 0c             	sub    $0xc,%esp
80101ec0:	53                   	push   %ebx
80101ec1:	e8 d6 1b 00 00       	call   80103a9c <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101ec6:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101ecb:	83 c4 10             	add    $0x10,%esp
80101ece:	85 c0                	test   %eax,%eax
80101ed0:	74 05                	je     80101ed7 <ideintr+0x7b>
    idestart(idequeue);
80101ed2:	e8 65 fe ff ff       	call   80101d3c <idestart>
    release(&idelock);
80101ed7:	83 ec 0c             	sub    $0xc,%esp
80101eda:	68 80 a5 10 80       	push   $0x8010a580
80101edf:	e8 00 22 00 00       	call   801040e4 <release>

  release(&idelock);
}
80101ee4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ee7:	5b                   	pop    %ebx
80101ee8:	5e                   	pop    %esi
80101ee9:	5f                   	pop    %edi
80101eea:	5d                   	pop    %ebp
80101eeb:	c3                   	ret    

80101eec <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101eec:	55                   	push   %ebp
80101eed:	89 e5                	mov    %esp,%ebp
80101eef:	53                   	push   %ebx
80101ef0:	83 ec 10             	sub    $0x10,%esp
80101ef3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101ef6:	8d 43 0c             	lea    0xc(%ebx),%eax
80101ef9:	50                   	push   %eax
80101efa:	e8 c1 1f 00 00       	call   80103ec0 <holdingsleep>
80101eff:	83 c4 10             	add    $0x10,%esp
80101f02:	85 c0                	test   %eax,%eax
80101f04:	0f 84 b7 00 00 00    	je     80101fc1 <iderw+0xd5>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101f0a:	8b 03                	mov    (%ebx),%eax
80101f0c:	83 e0 06             	and    $0x6,%eax
80101f0f:	83 f8 02             	cmp    $0x2,%eax
80101f12:	0f 84 9c 00 00 00    	je     80101fb4 <iderw+0xc8>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101f18:	8b 53 04             	mov    0x4(%ebx),%edx
80101f1b:	85 d2                	test   %edx,%edx
80101f1d:	74 09                	je     80101f28 <iderw+0x3c>
80101f1f:	a1 60 a5 10 80       	mov    0x8010a560,%eax
80101f24:	85 c0                	test   %eax,%eax
80101f26:	74 7f                	je     80101fa7 <iderw+0xbb>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101f28:	83 ec 0c             	sub    $0xc,%esp
80101f2b:	68 80 a5 10 80       	push   $0x8010a580
80101f30:	e8 17 21 00 00       	call   8010404c <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101f35:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101f3c:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101f41:	83 c4 10             	add    $0x10,%esp
80101f44:	85 c0                	test   %eax,%eax
80101f46:	74 58                	je     80101fa0 <iderw+0xb4>
80101f48:	89 c2                	mov    %eax,%edx
80101f4a:	8b 40 58             	mov    0x58(%eax),%eax
80101f4d:	85 c0                	test   %eax,%eax
80101f4f:	75 f7                	jne    80101f48 <iderw+0x5c>
80101f51:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
80101f54:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101f56:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
80101f5c:	74 36                	je     80101f94 <iderw+0xa8>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101f5e:	8b 03                	mov    (%ebx),%eax
80101f60:	83 e0 06             	and    $0x6,%eax
80101f63:	83 f8 02             	cmp    $0x2,%eax
80101f66:	74 1b                	je     80101f83 <iderw+0x97>
    sleep(b, &idelock);
80101f68:	83 ec 08             	sub    $0x8,%esp
80101f6b:	68 80 a5 10 80       	push   $0x8010a580
80101f70:	53                   	push   %ebx
80101f71:	e8 7a 19 00 00       	call   801038f0 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101f76:	8b 03                	mov    (%ebx),%eax
80101f78:	83 e0 06             	and    $0x6,%eax
80101f7b:	83 c4 10             	add    $0x10,%esp
80101f7e:	83 f8 02             	cmp    $0x2,%eax
80101f81:	75 e5                	jne    80101f68 <iderw+0x7c>
  }


  release(&idelock);
80101f83:	c7 45 08 80 a5 10 80 	movl   $0x8010a580,0x8(%ebp)
}
80101f8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f8d:	c9                   	leave  
  release(&idelock);
80101f8e:	e9 51 21 00 00       	jmp    801040e4 <release>
80101f93:	90                   	nop
    idestart(b);
80101f94:	89 d8                	mov    %ebx,%eax
80101f96:	e8 a1 fd ff ff       	call   80101d3c <idestart>
80101f9b:	eb c1                	jmp    80101f5e <iderw+0x72>
80101f9d:	8d 76 00             	lea    0x0(%esi),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101fa0:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101fa5:	eb ad                	jmp    80101f54 <iderw+0x68>
    panic("iderw: ide disk 1 not present");
80101fa7:	83 ec 0c             	sub    $0xc,%esp
80101faa:	68 b5 69 10 80       	push   $0x801069b5
80101faf:	e8 8c e3 ff ff       	call   80100340 <panic>
    panic("iderw: nothing to do");
80101fb4:	83 ec 0c             	sub    $0xc,%esp
80101fb7:	68 a0 69 10 80       	push   $0x801069a0
80101fbc:	e8 7f e3 ff ff       	call   80100340 <panic>
    panic("iderw: buf not locked");
80101fc1:	83 ec 0c             	sub    $0xc,%esp
80101fc4:	68 8a 69 10 80       	push   $0x8010698a
80101fc9:	e8 72 e3 ff ff       	call   80100340 <panic>
80101fce:	66 90                	xchg   %ax,%ax

80101fd0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
80101fd0:	55                   	push   %ebp
80101fd1:	89 e5                	mov    %esp,%ebp
80101fd3:	56                   	push   %esi
80101fd4:	53                   	push   %ebx
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101fd5:	c7 05 14 30 11 80 00 	movl   $0xfec00000,0x80113014
80101fdc:	00 c0 fe 
  ioapic->reg = reg;
80101fdf:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80101fe6:	00 00 00 
  return ioapic->data;
80101fe9:	8b 15 14 30 11 80    	mov    0x80113014,%edx
80101fef:	8b 72 10             	mov    0x10(%edx),%esi
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101ff2:	c1 ee 10             	shr    $0x10,%esi
80101ff5:	89 f0                	mov    %esi,%eax
80101ff7:	0f b6 f0             	movzbl %al,%esi
  ioapic->reg = reg;
80101ffa:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
80102000:	8b 0d 14 30 11 80    	mov    0x80113014,%ecx
80102006:	8b 41 10             	mov    0x10(%ecx),%eax
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
80102009:	0f b6 15 40 31 11 80 	movzbl 0x80113140,%edx
  id = ioapicread(REG_ID) >> 24;
80102010:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102013:	39 c2                	cmp    %eax,%edx
80102015:	74 16                	je     8010202d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102017:	83 ec 0c             	sub    $0xc,%esp
8010201a:	68 d4 69 10 80       	push   $0x801069d4
8010201f:	e8 fc e5 ff ff       	call   80100620 <cprintf>
80102024:	8b 0d 14 30 11 80    	mov    0x80113014,%ecx
8010202a:	83 c4 10             	add    $0x10,%esp
8010202d:	83 c6 21             	add    $0x21,%esi
{
80102030:	ba 10 00 00 00       	mov    $0x10,%edx
80102035:	b8 20 00 00 00       	mov    $0x20,%eax
8010203a:	66 90                	xchg   %ax,%ax

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010203c:	89 c3                	mov    %eax,%ebx
8010203e:	81 cb 00 00 01 00    	or     $0x10000,%ebx
  ioapic->reg = reg;
80102044:	89 11                	mov    %edx,(%ecx)
  ioapic->data = data;
80102046:	8b 0d 14 30 11 80    	mov    0x80113014,%ecx
8010204c:	89 59 10             	mov    %ebx,0x10(%ecx)
  ioapic->reg = reg;
8010204f:	8d 5a 01             	lea    0x1(%edx),%ebx
80102052:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
80102054:	8b 0d 14 30 11 80    	mov    0x80113014,%ecx
8010205a:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
80102061:	40                   	inc    %eax
80102062:	83 c2 02             	add    $0x2,%edx
80102065:	39 f0                	cmp    %esi,%eax
80102067:	75 d3                	jne    8010203c <ioapicinit+0x6c>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102069:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010206c:	5b                   	pop    %ebx
8010206d:	5e                   	pop    %esi
8010206e:	5d                   	pop    %ebp
8010206f:	c3                   	ret    

80102070 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102070:	55                   	push   %ebp
80102071:	89 e5                	mov    %esp,%ebp
80102073:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102076:	8d 50 20             	lea    0x20(%eax),%edx
80102079:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
8010207d:	8b 0d 14 30 11 80    	mov    0x80113014,%ecx
80102083:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80102085:	8b 0d 14 30 11 80    	mov    0x80113014,%ecx
8010208b:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010208e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102091:	c1 e2 18             	shl    $0x18,%edx
80102094:	40                   	inc    %eax
  ioapic->reg = reg;
80102095:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80102097:	a1 14 30 11 80       	mov    0x80113014,%eax
8010209c:	89 50 10             	mov    %edx,0x10(%eax)
}
8010209f:	5d                   	pop    %ebp
801020a0:	c3                   	ret    
801020a1:	66 90                	xchg   %ax,%ax
801020a3:	90                   	nop

801020a4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801020a4:	55                   	push   %ebp
801020a5:	89 e5                	mov    %esp,%ebp
801020a7:	53                   	push   %ebx
801020a8:	53                   	push   %ebx
801020a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801020ac:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
801020b2:	75 70                	jne    80102124 <kfree+0x80>
801020b4:	81 fb 88 5f 11 80    	cmp    $0x80115f88,%ebx
801020ba:	72 68                	jb     80102124 <kfree+0x80>
801020bc:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801020c2:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801020c7:	77 5b                	ja     80102124 <kfree+0x80>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801020c9:	52                   	push   %edx
801020ca:	68 00 10 00 00       	push   $0x1000
801020cf:	6a 01                	push   $0x1
801020d1:	53                   	push   %ebx
801020d2:	e8 55 20 00 00       	call   8010412c <memset>

  if(kmem.use_lock)
801020d7:	83 c4 10             	add    $0x10,%esp
801020da:	8b 0d 54 30 11 80    	mov    0x80113054,%ecx
801020e0:	85 c9                	test   %ecx,%ecx
801020e2:	75 1c                	jne    80102100 <kfree+0x5c>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
801020e4:	a1 58 30 11 80       	mov    0x80113058,%eax
801020e9:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
801020eb:	89 1d 58 30 11 80    	mov    %ebx,0x80113058
  if(kmem.use_lock)
801020f1:	a1 54 30 11 80       	mov    0x80113054,%eax
801020f6:	85 c0                	test   %eax,%eax
801020f8:	75 1a                	jne    80102114 <kfree+0x70>
    release(&kmem.lock);
}
801020fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020fd:	c9                   	leave  
801020fe:	c3                   	ret    
801020ff:	90                   	nop
    acquire(&kmem.lock);
80102100:	83 ec 0c             	sub    $0xc,%esp
80102103:	68 20 30 11 80       	push   $0x80113020
80102108:	e8 3f 1f 00 00       	call   8010404c <acquire>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	eb d2                	jmp    801020e4 <kfree+0x40>
80102112:	66 90                	xchg   %ax,%ax
    release(&kmem.lock);
80102114:	c7 45 08 20 30 11 80 	movl   $0x80113020,0x8(%ebp)
}
8010211b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010211e:	c9                   	leave  
    release(&kmem.lock);
8010211f:	e9 c0 1f 00 00       	jmp    801040e4 <release>
    panic("kfree");
80102124:	83 ec 0c             	sub    $0xc,%esp
80102127:	68 06 6a 10 80       	push   $0x80106a06
8010212c:	e8 0f e2 ff ff       	call   80100340 <panic>
80102131:	8d 76 00             	lea    0x0(%esi),%esi

80102134 <freerange>:
{
80102134:	55                   	push   %ebp
80102135:	89 e5                	mov    %esp,%ebp
80102137:	56                   	push   %esi
80102138:	53                   	push   %ebx
80102139:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
8010213c:	8b 45 08             	mov    0x8(%ebp),%eax
8010213f:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102145:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010214b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80102151:	39 de                	cmp    %ebx,%esi
80102153:	72 1f                	jb     80102174 <freerange+0x40>
80102155:	8d 76 00             	lea    0x0(%esi),%esi
    kfree(p);
80102158:	83 ec 0c             	sub    $0xc,%esp
8010215b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
80102161:	50                   	push   %eax
80102162:	e8 3d ff ff ff       	call   801020a4 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102167:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010216d:	83 c4 10             	add    $0x10,%esp
80102170:	39 f3                	cmp    %esi,%ebx
80102172:	76 e4                	jbe    80102158 <freerange+0x24>
}
80102174:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102177:	5b                   	pop    %ebx
80102178:	5e                   	pop    %esi
80102179:	5d                   	pop    %ebp
8010217a:	c3                   	ret    
8010217b:	90                   	nop

8010217c <kinit1>:
{
8010217c:	55                   	push   %ebp
8010217d:	89 e5                	mov    %esp,%ebp
8010217f:	56                   	push   %esi
80102180:	53                   	push   %ebx
80102181:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102184:	83 ec 08             	sub    $0x8,%esp
80102187:	68 0c 6a 10 80       	push   $0x80106a0c
8010218c:	68 20 30 11 80       	push   $0x80113020
80102191:	e8 76 1d 00 00       	call   80103f0c <initlock>
  kmem.use_lock = 0;
80102196:	c7 05 54 30 11 80 00 	movl   $0x0,0x80113054
8010219d:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
801021a0:	8b 45 08             	mov    0x8(%ebp),%eax
801021a3:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801021a9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801021af:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801021b5:	83 c4 10             	add    $0x10,%esp
801021b8:	39 de                	cmp    %ebx,%esi
801021ba:	72 1c                	jb     801021d8 <kinit1+0x5c>
    kfree(p);
801021bc:	83 ec 0c             	sub    $0xc,%esp
801021bf:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
801021c5:	50                   	push   %eax
801021c6:	e8 d9 fe ff ff       	call   801020a4 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801021cb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801021d1:	83 c4 10             	add    $0x10,%esp
801021d4:	39 de                	cmp    %ebx,%esi
801021d6:	73 e4                	jae    801021bc <kinit1+0x40>
}
801021d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801021db:	5b                   	pop    %ebx
801021dc:	5e                   	pop    %esi
801021dd:	5d                   	pop    %ebp
801021de:	c3                   	ret    
801021df:	90                   	nop

801021e0 <kinit2>:
{
801021e0:	55                   	push   %ebp
801021e1:	89 e5                	mov    %esp,%ebp
801021e3:	56                   	push   %esi
801021e4:	53                   	push   %ebx
801021e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
801021e8:	8b 45 08             	mov    0x8(%ebp),%eax
801021eb:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801021f1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801021f7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801021fd:	39 de                	cmp    %ebx,%esi
801021ff:	72 1f                	jb     80102220 <kinit2+0x40>
80102201:	8d 76 00             	lea    0x0(%esi),%esi
    kfree(p);
80102204:	83 ec 0c             	sub    $0xc,%esp
80102207:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
8010220d:	50                   	push   %eax
8010220e:	e8 91 fe ff ff       	call   801020a4 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102213:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80102219:	83 c4 10             	add    $0x10,%esp
8010221c:	39 de                	cmp    %ebx,%esi
8010221e:	73 e4                	jae    80102204 <kinit2+0x24>
  kmem.use_lock = 1;
80102220:	c7 05 54 30 11 80 01 	movl   $0x1,0x80113054
80102227:	00 00 00 
}
8010222a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010222d:	5b                   	pop    %ebx
8010222e:	5e                   	pop    %esi
8010222f:	5d                   	pop    %ebp
80102230:	c3                   	ret    
80102231:	8d 76 00             	lea    0x0(%esi),%esi

80102234 <kalloc>:
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
80102234:	a1 54 30 11 80       	mov    0x80113054,%eax
80102239:	85 c0                	test   %eax,%eax
8010223b:	75 17                	jne    80102254 <kalloc+0x20>
    acquire(&kmem.lock);
  r = kmem.freelist;
8010223d:	a1 58 30 11 80       	mov    0x80113058,%eax
  if(r)
80102242:	85 c0                	test   %eax,%eax
80102244:	74 0a                	je     80102250 <kalloc+0x1c>
    kmem.freelist = r->next;
80102246:	8b 10                	mov    (%eax),%edx
80102248:	89 15 58 30 11 80    	mov    %edx,0x80113058
  if(kmem.use_lock)
8010224e:	c3                   	ret    
8010224f:	90                   	nop
    release(&kmem.lock);
  return (char*)r;
}
80102250:	c3                   	ret    
80102251:	8d 76 00             	lea    0x0(%esi),%esi
{
80102254:	55                   	push   %ebp
80102255:	89 e5                	mov    %esp,%ebp
80102257:	83 ec 24             	sub    $0x24,%esp
    acquire(&kmem.lock);
8010225a:	68 20 30 11 80       	push   $0x80113020
8010225f:	e8 e8 1d 00 00       	call   8010404c <acquire>
  r = kmem.freelist;
80102264:	a1 58 30 11 80       	mov    0x80113058,%eax
  if(r)
80102269:	83 c4 10             	add    $0x10,%esp
8010226c:	8b 15 54 30 11 80    	mov    0x80113054,%edx
80102272:	85 c0                	test   %eax,%eax
80102274:	74 08                	je     8010227e <kalloc+0x4a>
    kmem.freelist = r->next;
80102276:	8b 08                	mov    (%eax),%ecx
80102278:	89 0d 58 30 11 80    	mov    %ecx,0x80113058
  if(kmem.use_lock)
8010227e:	85 d2                	test   %edx,%edx
80102280:	74 16                	je     80102298 <kalloc+0x64>
80102282:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&kmem.lock);
80102285:	83 ec 0c             	sub    $0xc,%esp
80102288:	68 20 30 11 80       	push   $0x80113020
8010228d:	e8 52 1e 00 00       	call   801040e4 <release>
80102292:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102295:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102298:	c9                   	leave  
80102299:	c3                   	ret    
8010229a:	66 90                	xchg   %ax,%ax

8010229c <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010229c:	ba 64 00 00 00       	mov    $0x64,%edx
801022a1:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801022a2:	a8 01                	test   $0x1,%al
801022a4:	0f 84 ae 00 00 00    	je     80102358 <kbdgetc+0xbc>
{
801022aa:	55                   	push   %ebp
801022ab:	89 e5                	mov    %esp,%ebp
801022ad:	53                   	push   %ebx
801022ae:	ba 60 00 00 00       	mov    $0x60,%edx
801022b3:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801022b4:	0f b6 d8             	movzbl %al,%ebx

  if(data == 0xE0){
801022b7:	8b 15 b4 a5 10 80    	mov    0x8010a5b4,%edx
801022bd:	3c e0                	cmp    $0xe0,%al
801022bf:	74 5b                	je     8010231c <kbdgetc+0x80>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801022c1:	89 d1                	mov    %edx,%ecx
801022c3:	83 e1 40             	and    $0x40,%ecx
801022c6:	84 c0                	test   %al,%al
801022c8:	78 62                	js     8010232c <kbdgetc+0x90>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801022ca:	85 c9                	test   %ecx,%ecx
801022cc:	74 09                	je     801022d7 <kbdgetc+0x3b>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801022ce:	83 c8 80             	or     $0xffffff80,%eax
801022d1:	0f b6 d8             	movzbl %al,%ebx
    shift &= ~E0ESC;
801022d4:	83 e2 bf             	and    $0xffffffbf,%edx
  }

  shift |= shiftcode[data];
801022d7:	0f b6 8b 40 6b 10 80 	movzbl -0x7fef94c0(%ebx),%ecx
801022de:	09 d1                	or     %edx,%ecx
  shift ^= togglecode[data];
801022e0:	0f b6 83 40 6a 10 80 	movzbl -0x7fef95c0(%ebx),%eax
801022e7:	31 c1                	xor    %eax,%ecx
801022e9:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
801022ef:	89 c8                	mov    %ecx,%eax
801022f1:	83 e0 03             	and    $0x3,%eax
801022f4:	8b 04 85 20 6a 10 80 	mov    -0x7fef95e0(,%eax,4),%eax
801022fb:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
  if(shift & CAPSLOCK){
801022ff:	83 e1 08             	and    $0x8,%ecx
80102302:	74 13                	je     80102317 <kbdgetc+0x7b>
    if('a' <= c && c <= 'z')
80102304:	8d 50 9f             	lea    -0x61(%eax),%edx
80102307:	83 fa 19             	cmp    $0x19,%edx
8010230a:	76 44                	jbe    80102350 <kbdgetc+0xb4>
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
8010230c:	8d 50 bf             	lea    -0x41(%eax),%edx
8010230f:	83 fa 19             	cmp    $0x19,%edx
80102312:	77 03                	ja     80102317 <kbdgetc+0x7b>
      c += 'a' - 'A';
80102314:	83 c0 20             	add    $0x20,%eax
  }
  return c;
}
80102317:	5b                   	pop    %ebx
80102318:	5d                   	pop    %ebp
80102319:	c3                   	ret    
8010231a:	66 90                	xchg   %ax,%ax
    shift |= E0ESC;
8010231c:	83 ca 40             	or     $0x40,%edx
8010231f:	89 15 b4 a5 10 80    	mov    %edx,0x8010a5b4
    return 0;
80102325:	31 c0                	xor    %eax,%eax
}
80102327:	5b                   	pop    %ebx
80102328:	5d                   	pop    %ebp
80102329:	c3                   	ret    
8010232a:	66 90                	xchg   %ax,%ax
    data = (shift & E0ESC ? data : data & 0x7F);
8010232c:	85 c9                	test   %ecx,%ecx
8010232e:	75 05                	jne    80102335 <kbdgetc+0x99>
80102330:	89 c3                	mov    %eax,%ebx
80102332:	83 e3 7f             	and    $0x7f,%ebx
    shift &= ~(shiftcode[data] | E0ESC);
80102335:	8a 8b 40 6b 10 80    	mov    -0x7fef94c0(%ebx),%cl
8010233b:	83 c9 40             	or     $0x40,%ecx
8010233e:	0f b6 c9             	movzbl %cl,%ecx
80102341:	f7 d1                	not    %ecx
80102343:	21 d1                	and    %edx,%ecx
80102345:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
    return 0;
8010234b:	31 c0                	xor    %eax,%eax
}
8010234d:	5b                   	pop    %ebx
8010234e:	5d                   	pop    %ebp
8010234f:	c3                   	ret    
      c += 'A' - 'a';
80102350:	83 e8 20             	sub    $0x20,%eax
}
80102353:	5b                   	pop    %ebx
80102354:	5d                   	pop    %ebp
80102355:	c3                   	ret    
80102356:	66 90                	xchg   %ax,%ax
    return -1;
80102358:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010235d:	c3                   	ret    
8010235e:	66 90                	xchg   %ax,%ax

80102360 <kbdintr>:

void
kbdintr(void)
{
80102360:	55                   	push   %ebp
80102361:	89 e5                	mov    %esp,%ebp
80102363:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102366:	68 9c 22 10 80       	push   $0x8010229c
8010236b:	e8 38 e4 ff ff       	call   801007a8 <consoleintr>
}
80102370:	83 c4 10             	add    $0x10,%esp
80102373:	c9                   	leave  
80102374:	c3                   	ret    
80102375:	66 90                	xchg   %ax,%ax
80102377:	90                   	nop

80102378 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
80102378:	a1 5c 30 11 80       	mov    0x8011305c,%eax
8010237d:	85 c0                	test   %eax,%eax
8010237f:	0f 84 c3 00 00 00    	je     80102448 <lapicinit+0xd0>
  lapic[index] = value;
80102385:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
8010238c:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010238f:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102392:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102399:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010239c:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010239f:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
801023a6:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
801023a9:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801023ac:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
801023b3:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
801023b6:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801023b9:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
801023c0:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801023c3:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801023c6:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
801023cd:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801023d0:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801023d3:	8b 50 30             	mov    0x30(%eax),%edx
801023d6:	c1 ea 10             	shr    $0x10,%edx
801023d9:	81 e2 fc 00 00 00    	and    $0xfc,%edx
801023df:	75 6b                	jne    8010244c <lapicinit+0xd4>
  lapic[index] = value;
801023e1:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
801023e8:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801023eb:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801023ee:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801023f5:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801023f8:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801023fb:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102402:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102405:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102408:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
8010240f:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102412:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102415:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
8010241c:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010241f:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102422:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
80102429:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
8010242c:	8b 50 20             	mov    0x20(%eax),%edx
8010242f:	90                   	nop
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102430:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
80102436:	80 e6 10             	and    $0x10,%dh
80102439:	75 f5                	jne    80102430 <lapicinit+0xb8>
  lapic[index] = value;
8010243b:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102442:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102445:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102448:	c3                   	ret    
80102449:	8d 76 00             	lea    0x0(%esi),%esi
  lapic[index] = value;
8010244c:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102453:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102456:	8b 50 20             	mov    0x20(%eax),%edx
}
80102459:	eb 86                	jmp    801023e1 <lapicinit+0x69>
8010245b:	90                   	nop

8010245c <lapicid>:

int
lapicid(void)
{
  if (!lapic)
8010245c:	a1 5c 30 11 80       	mov    0x8011305c,%eax
80102461:	85 c0                	test   %eax,%eax
80102463:	74 07                	je     8010246c <lapicid+0x10>
    return 0;
  return lapic[ID] >> 24;
80102465:	8b 40 20             	mov    0x20(%eax),%eax
80102468:	c1 e8 18             	shr    $0x18,%eax
8010246b:	c3                   	ret    
    return 0;
8010246c:	31 c0                	xor    %eax,%eax
}
8010246e:	c3                   	ret    
8010246f:	90                   	nop

80102470 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102470:	a1 5c 30 11 80       	mov    0x8011305c,%eax
80102475:	85 c0                	test   %eax,%eax
80102477:	74 0d                	je     80102486 <lapiceoi+0x16>
  lapic[index] = value;
80102479:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102480:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102483:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102486:	c3                   	ret    
80102487:	90                   	nop

80102488 <microdelay>:
// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
}
80102488:	c3                   	ret    
80102489:	8d 76 00             	lea    0x0(%esi),%esi

8010248c <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010248c:	55                   	push   %ebp
8010248d:	89 e5                	mov    %esp,%ebp
8010248f:	53                   	push   %ebx
80102490:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102493:	8b 4d 0c             	mov    0xc(%ebp),%ecx
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102496:	b0 0f                	mov    $0xf,%al
80102498:	ba 70 00 00 00       	mov    $0x70,%edx
8010249d:	ee                   	out    %al,(%dx)
8010249e:	b0 0a                	mov    $0xa,%al
801024a0:	ba 71 00 00 00       	mov    $0x71,%edx
801024a5:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
801024a6:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801024ad:	00 00 
  wrv[1] = addr >> 4;
801024af:	89 c8                	mov    %ecx,%eax
801024b1:	c1 e8 04             	shr    $0x4,%eax
801024b4:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
801024ba:	a1 5c 30 11 80       	mov    0x8011305c,%eax

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801024bf:	c1 e3 18             	shl    $0x18,%ebx
801024c2:	89 da                	mov    %ebx,%edx
  lapic[index] = value;
801024c4:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801024ca:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801024cd:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
801024d4:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
801024d7:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801024da:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
801024e1:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
801024e4:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801024e7:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801024ed:	8b 58 20             	mov    0x20(%eax),%ebx
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
801024f0:	c1 e9 0c             	shr    $0xc,%ecx
801024f3:	80 cd 06             	or     $0x6,%ch
  lapic[index] = value;
801024f6:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801024fc:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801024ff:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102505:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102508:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010250e:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
80102511:	5b                   	pop    %ebx
80102512:	5d                   	pop    %ebp
80102513:	c3                   	ret    

80102514 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102514:	55                   	push   %ebp
80102515:	89 e5                	mov    %esp,%ebp
80102517:	57                   	push   %edi
80102518:	56                   	push   %esi
80102519:	53                   	push   %ebx
8010251a:	83 ec 4c             	sub    $0x4c,%esp
8010251d:	b0 0b                	mov    $0xb,%al
8010251f:	ba 70 00 00 00       	mov    $0x70,%edx
80102524:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102525:	ba 71 00 00 00       	mov    $0x71,%edx
8010252a:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
8010252b:	83 e0 04             	and    $0x4,%eax
8010252e:	88 45 b2             	mov    %al,-0x4e(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102531:	be 70 00 00 00       	mov    $0x70,%esi
80102536:	66 90                	xchg   %ax,%ax
80102538:	31 c0                	xor    %eax,%eax
8010253a:	89 f2                	mov    %esi,%edx
8010253c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010253d:	bb 71 00 00 00       	mov    $0x71,%ebx
80102542:	89 da                	mov    %ebx,%edx
80102544:	ec                   	in     (%dx),%al
80102545:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102548:	bf 02 00 00 00       	mov    $0x2,%edi
8010254d:	89 f8                	mov    %edi,%eax
8010254f:	89 f2                	mov    %esi,%edx
80102551:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102552:	89 da                	mov    %ebx,%edx
80102554:	ec                   	in     (%dx),%al
80102555:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102558:	b0 04                	mov    $0x4,%al
8010255a:	89 f2                	mov    %esi,%edx
8010255c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010255d:	89 da                	mov    %ebx,%edx
8010255f:	ec                   	in     (%dx),%al
80102560:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102563:	b0 07                	mov    $0x7,%al
80102565:	89 f2                	mov    %esi,%edx
80102567:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102568:	89 da                	mov    %ebx,%edx
8010256a:	ec                   	in     (%dx),%al
8010256b:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010256e:	b0 08                	mov    $0x8,%al
80102570:	89 f2                	mov    %esi,%edx
80102572:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102573:	89 da                	mov    %ebx,%edx
80102575:	ec                   	in     (%dx),%al
80102576:	88 45 b3             	mov    %al,-0x4d(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102579:	b0 09                	mov    $0x9,%al
8010257b:	89 f2                	mov    %esi,%edx
8010257d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010257e:	89 da                	mov    %ebx,%edx
80102580:	ec                   	in     (%dx),%al
80102581:	0f b6 c8             	movzbl %al,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102584:	b0 0a                	mov    $0xa,%al
80102586:	89 f2                	mov    %esi,%edx
80102588:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102589:	89 da                	mov    %ebx,%edx
8010258b:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010258c:	84 c0                	test   %al,%al
8010258e:	78 a8                	js     80102538 <cmostime+0x24>
  return inb(CMOS_RETURN);
80102590:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102594:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102597:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
8010259b:	89 45 bc             	mov    %eax,-0x44(%ebp)
8010259e:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
801025a2:	89 45 c0             	mov    %eax,-0x40(%ebp)
801025a5:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
801025a9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
801025ac:	0f b6 45 b3          	movzbl -0x4d(%ebp),%eax
801025b0:	89 45 c8             	mov    %eax,-0x38(%ebp)
801025b3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025b6:	31 c0                	xor    %eax,%eax
801025b8:	89 f2                	mov    %esi,%edx
801025ba:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025bb:	89 da                	mov    %ebx,%edx
801025bd:	ec                   	in     (%dx),%al
801025be:	0f b6 c0             	movzbl %al,%eax
801025c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025c4:	89 f8                	mov    %edi,%eax
801025c6:	89 f2                	mov    %esi,%edx
801025c8:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025c9:	89 da                	mov    %ebx,%edx
801025cb:	ec                   	in     (%dx),%al
801025cc:	0f b6 c0             	movzbl %al,%eax
801025cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025d2:	b0 04                	mov    $0x4,%al
801025d4:	89 f2                	mov    %esi,%edx
801025d6:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025d7:	89 da                	mov    %ebx,%edx
801025d9:	ec                   	in     (%dx),%al
801025da:	0f b6 c0             	movzbl %al,%eax
801025dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025e0:	b0 07                	mov    $0x7,%al
801025e2:	89 f2                	mov    %esi,%edx
801025e4:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025e5:	89 da                	mov    %ebx,%edx
801025e7:	ec                   	in     (%dx),%al
801025e8:	0f b6 c0             	movzbl %al,%eax
801025eb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025ee:	b0 08                	mov    $0x8,%al
801025f0:	89 f2                	mov    %esi,%edx
801025f2:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025f3:	89 da                	mov    %ebx,%edx
801025f5:	ec                   	in     (%dx),%al
801025f6:	0f b6 c0             	movzbl %al,%eax
801025f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025fc:	b0 09                	mov    $0x9,%al
801025fe:	89 f2                	mov    %esi,%edx
80102600:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102601:	89 da                	mov    %ebx,%edx
80102603:	ec                   	in     (%dx),%al
80102604:	0f b6 c0             	movzbl %al,%eax
80102607:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010260a:	50                   	push   %eax
8010260b:	6a 18                	push   $0x18
8010260d:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102610:	50                   	push   %eax
80102611:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102614:	50                   	push   %eax
80102615:	e8 5e 1b 00 00       	call   80104178 <memcmp>
8010261a:	83 c4 10             	add    $0x10,%esp
8010261d:	85 c0                	test   %eax,%eax
8010261f:	0f 85 13 ff ff ff    	jne    80102538 <cmostime+0x24>
      break;
  }

  // convert
  if(bcd) {
80102625:	80 7d b2 00          	cmpb   $0x0,-0x4e(%ebp)
80102629:	75 7e                	jne    801026a9 <cmostime+0x195>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010262b:	8b 55 b8             	mov    -0x48(%ebp),%edx
8010262e:	89 d0                	mov    %edx,%eax
80102630:	c1 e8 04             	shr    $0x4,%eax
80102633:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102636:	01 c0                	add    %eax,%eax
80102638:	83 e2 0f             	and    $0xf,%edx
8010263b:	01 d0                	add    %edx,%eax
8010263d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102640:	8b 55 bc             	mov    -0x44(%ebp),%edx
80102643:	89 d0                	mov    %edx,%eax
80102645:	c1 e8 04             	shr    $0x4,%eax
80102648:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010264b:	01 c0                	add    %eax,%eax
8010264d:	83 e2 0f             	and    $0xf,%edx
80102650:	01 d0                	add    %edx,%eax
80102652:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102655:	8b 55 c0             	mov    -0x40(%ebp),%edx
80102658:	89 d0                	mov    %edx,%eax
8010265a:	c1 e8 04             	shr    $0x4,%eax
8010265d:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102660:	01 c0                	add    %eax,%eax
80102662:	83 e2 0f             	and    $0xf,%edx
80102665:	01 d0                	add    %edx,%eax
80102667:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
8010266a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
8010266d:	89 d0                	mov    %edx,%eax
8010266f:	c1 e8 04             	shr    $0x4,%eax
80102672:	8d 04 80             	lea    (%eax,%eax,4),%eax
80102675:	01 c0                	add    %eax,%eax
80102677:	83 e2 0f             	and    $0xf,%edx
8010267a:	01 d0                	add    %edx,%eax
8010267c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
8010267f:	8b 55 c8             	mov    -0x38(%ebp),%edx
80102682:	89 d0                	mov    %edx,%eax
80102684:	c1 e8 04             	shr    $0x4,%eax
80102687:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010268a:	01 c0                	add    %eax,%eax
8010268c:	83 e2 0f             	and    $0xf,%edx
8010268f:	01 d0                	add    %edx,%eax
80102691:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102694:	8b 55 cc             	mov    -0x34(%ebp),%edx
80102697:	89 d0                	mov    %edx,%eax
80102699:	c1 e8 04             	shr    $0x4,%eax
8010269c:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010269f:	01 c0                	add    %eax,%eax
801026a1:	83 e2 0f             	and    $0xf,%edx
801026a4:	01 d0                	add    %edx,%eax
801026a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
801026a9:	b9 06 00 00 00       	mov    $0x6,%ecx
801026ae:	8b 7d 08             	mov    0x8(%ebp),%edi
801026b1:	8d 75 b8             	lea    -0x48(%ebp),%esi
801026b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801026b6:	8b 45 08             	mov    0x8(%ebp),%eax
801026b9:	81 40 14 d0 07 00 00 	addl   $0x7d0,0x14(%eax)
}
801026c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801026c3:	5b                   	pop    %ebx
801026c4:	5e                   	pop    %esi
801026c5:	5f                   	pop    %edi
801026c6:	5d                   	pop    %ebp
801026c7:	c3                   	ret    

801026c8 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801026c8:	8b 0d a8 30 11 80    	mov    0x801130a8,%ecx
801026ce:	85 c9                	test   %ecx,%ecx
801026d0:	7e 7e                	jle    80102750 <install_trans+0x88>
{
801026d2:	55                   	push   %ebp
801026d3:	89 e5                	mov    %esp,%ebp
801026d5:	57                   	push   %edi
801026d6:	56                   	push   %esi
801026d7:	53                   	push   %ebx
801026d8:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801026db:	31 f6                	xor    %esi,%esi
801026dd:	8d 76 00             	lea    0x0(%esi),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801026e0:	83 ec 08             	sub    $0x8,%esp
801026e3:	a1 94 30 11 80       	mov    0x80113094,%eax
801026e8:	01 f0                	add    %esi,%eax
801026ea:	40                   	inc    %eax
801026eb:	50                   	push   %eax
801026ec:	ff 35 a4 30 11 80    	pushl  0x801130a4
801026f2:	e8 bd d9 ff ff       	call   801000b4 <bread>
801026f7:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801026f9:	58                   	pop    %eax
801026fa:	5a                   	pop    %edx
801026fb:	ff 34 b5 ac 30 11 80 	pushl  -0x7feecf54(,%esi,4)
80102702:	ff 35 a4 30 11 80    	pushl  0x801130a4
80102708:	e8 a7 d9 ff ff       	call   801000b4 <bread>
8010270d:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010270f:	83 c4 0c             	add    $0xc,%esp
80102712:	68 00 02 00 00       	push   $0x200
80102717:	8d 47 5c             	lea    0x5c(%edi),%eax
8010271a:	50                   	push   %eax
8010271b:	8d 43 5c             	lea    0x5c(%ebx),%eax
8010271e:	50                   	push   %eax
8010271f:	e8 8c 1a 00 00       	call   801041b0 <memmove>
    bwrite(dbuf);  // write dst to disk
80102724:	89 1c 24             	mov    %ebx,(%esp)
80102727:	e8 5c da ff ff       	call   80100188 <bwrite>
    brelse(lbuf);
8010272c:	89 3c 24             	mov    %edi,(%esp)
8010272f:	e8 8c da ff ff       	call   801001c0 <brelse>
    brelse(dbuf);
80102734:	89 1c 24             	mov    %ebx,(%esp)
80102737:	e8 84 da ff ff       	call   801001c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010273c:	46                   	inc    %esi
8010273d:	83 c4 10             	add    $0x10,%esp
80102740:	39 35 a8 30 11 80    	cmp    %esi,0x801130a8
80102746:	7f 98                	jg     801026e0 <install_trans+0x18>
  }
}
80102748:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010274b:	5b                   	pop    %ebx
8010274c:	5e                   	pop    %esi
8010274d:	5f                   	pop    %edi
8010274e:	5d                   	pop    %ebp
8010274f:	c3                   	ret    
80102750:	c3                   	ret    
80102751:	8d 76 00             	lea    0x0(%esi),%esi

80102754 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102754:	55                   	push   %ebp
80102755:	89 e5                	mov    %esp,%ebp
80102757:	53                   	push   %ebx
80102758:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010275b:	ff 35 94 30 11 80    	pushl  0x80113094
80102761:	ff 35 a4 30 11 80    	pushl  0x801130a4
80102767:	e8 48 d9 ff ff       	call   801000b4 <bread>
8010276c:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
8010276e:	a1 a8 30 11 80       	mov    0x801130a8,%eax
80102773:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102776:	83 c4 10             	add    $0x10,%esp
80102779:	85 c0                	test   %eax,%eax
8010277b:	7e 13                	jle    80102790 <write_head+0x3c>
8010277d:	31 d2                	xor    %edx,%edx
8010277f:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102780:	8b 0c 95 ac 30 11 80 	mov    -0x7feecf54(,%edx,4),%ecx
80102787:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010278b:	42                   	inc    %edx
8010278c:	39 d0                	cmp    %edx,%eax
8010278e:	75 f0                	jne    80102780 <write_head+0x2c>
  }
  bwrite(buf);
80102790:	83 ec 0c             	sub    $0xc,%esp
80102793:	53                   	push   %ebx
80102794:	e8 ef d9 ff ff       	call   80100188 <bwrite>
  brelse(buf);
80102799:	89 1c 24             	mov    %ebx,(%esp)
8010279c:	e8 1f da ff ff       	call   801001c0 <brelse>
}
801027a1:	83 c4 10             	add    $0x10,%esp
801027a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027a7:	c9                   	leave  
801027a8:	c3                   	ret    
801027a9:	8d 76 00             	lea    0x0(%esi),%esi

801027ac <initlog>:
{
801027ac:	55                   	push   %ebp
801027ad:	89 e5                	mov    %esp,%ebp
801027af:	53                   	push   %ebx
801027b0:	83 ec 2c             	sub    $0x2c,%esp
801027b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801027b6:	68 40 6c 10 80       	push   $0x80106c40
801027bb:	68 60 30 11 80       	push   $0x80113060
801027c0:	e8 47 17 00 00       	call   80103f0c <initlock>
  readsb(dev, &sb);
801027c5:	58                   	pop    %eax
801027c6:	5a                   	pop    %edx
801027c7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801027ca:	50                   	push   %eax
801027cb:	53                   	push   %ebx
801027cc:	e8 6f eb ff ff       	call   80101340 <readsb>
  log.start = sb.logstart;
801027d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027d4:	a3 94 30 11 80       	mov    %eax,0x80113094
  log.size = sb.nlog;
801027d9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801027dc:	89 15 98 30 11 80    	mov    %edx,0x80113098
  log.dev = dev;
801027e2:	89 1d a4 30 11 80    	mov    %ebx,0x801130a4
  struct buf *buf = bread(log.dev, log.start);
801027e8:	59                   	pop    %ecx
801027e9:	5a                   	pop    %edx
801027ea:	50                   	push   %eax
801027eb:	53                   	push   %ebx
801027ec:	e8 c3 d8 ff ff       	call   801000b4 <bread>
  log.lh.n = lh->n;
801027f1:	8b 48 5c             	mov    0x5c(%eax),%ecx
801027f4:	89 0d a8 30 11 80    	mov    %ecx,0x801130a8
  for (i = 0; i < log.lh.n; i++) {
801027fa:	83 c4 10             	add    $0x10,%esp
801027fd:	85 c9                	test   %ecx,%ecx
801027ff:	7e 13                	jle    80102814 <initlog+0x68>
80102801:	31 d2                	xor    %edx,%edx
80102803:	90                   	nop
    log.lh.block[i] = lh->block[i];
80102804:	8b 5c 90 60          	mov    0x60(%eax,%edx,4),%ebx
80102808:	89 1c 95 ac 30 11 80 	mov    %ebx,-0x7feecf54(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010280f:	42                   	inc    %edx
80102810:	39 d1                	cmp    %edx,%ecx
80102812:	75 f0                	jne    80102804 <initlog+0x58>
  brelse(buf);
80102814:	83 ec 0c             	sub    $0xc,%esp
80102817:	50                   	push   %eax
80102818:	e8 a3 d9 ff ff       	call   801001c0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
8010281d:	e8 a6 fe ff ff       	call   801026c8 <install_trans>
  log.lh.n = 0;
80102822:	c7 05 a8 30 11 80 00 	movl   $0x0,0x801130a8
80102829:	00 00 00 
  write_head(); // clear the log
8010282c:	e8 23 ff ff ff       	call   80102754 <write_head>
}
80102831:	83 c4 10             	add    $0x10,%esp
80102834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102837:	c9                   	leave  
80102838:	c3                   	ret    
80102839:	8d 76 00             	lea    0x0(%esi),%esi

8010283c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
8010283c:	55                   	push   %ebp
8010283d:	89 e5                	mov    %esp,%ebp
8010283f:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102842:	68 60 30 11 80       	push   $0x80113060
80102847:	e8 00 18 00 00       	call   8010404c <acquire>
8010284c:	83 c4 10             	add    $0x10,%esp
8010284f:	eb 18                	jmp    80102869 <begin_op+0x2d>
80102851:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102854:	83 ec 08             	sub    $0x8,%esp
80102857:	68 60 30 11 80       	push   $0x80113060
8010285c:	68 60 30 11 80       	push   $0x80113060
80102861:	e8 8a 10 00 00       	call   801038f0 <sleep>
80102866:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102869:	a1 a0 30 11 80       	mov    0x801130a0,%eax
8010286e:	85 c0                	test   %eax,%eax
80102870:	75 e2                	jne    80102854 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102872:	a1 9c 30 11 80       	mov    0x8011309c,%eax
80102877:	8d 50 01             	lea    0x1(%eax),%edx
8010287a:	8d 44 80 05          	lea    0x5(%eax,%eax,4),%eax
8010287e:	01 c0                	add    %eax,%eax
80102880:	03 05 a8 30 11 80    	add    0x801130a8,%eax
80102886:	83 f8 1e             	cmp    $0x1e,%eax
80102889:	7f c9                	jg     80102854 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
8010288b:	89 15 9c 30 11 80    	mov    %edx,0x8011309c
      release(&log.lock);
80102891:	83 ec 0c             	sub    $0xc,%esp
80102894:	68 60 30 11 80       	push   $0x80113060
80102899:	e8 46 18 00 00       	call   801040e4 <release>
      break;
    }
  }
}
8010289e:	83 c4 10             	add    $0x10,%esp
801028a1:	c9                   	leave  
801028a2:	c3                   	ret    
801028a3:	90                   	nop

801028a4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801028a4:	55                   	push   %ebp
801028a5:	89 e5                	mov    %esp,%ebp
801028a7:	57                   	push   %edi
801028a8:	56                   	push   %esi
801028a9:	53                   	push   %ebx
801028aa:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
801028ad:	68 60 30 11 80       	push   $0x80113060
801028b2:	e8 95 17 00 00       	call   8010404c <acquire>
  log.outstanding -= 1;
801028b7:	a1 9c 30 11 80       	mov    0x8011309c,%eax
801028bc:	8d 58 ff             	lea    -0x1(%eax),%ebx
801028bf:	89 1d 9c 30 11 80    	mov    %ebx,0x8011309c
  if(log.committing)
801028c5:	83 c4 10             	add    $0x10,%esp
801028c8:	8b 35 a0 30 11 80    	mov    0x801130a0,%esi
801028ce:	85 f6                	test   %esi,%esi
801028d0:	0f 85 12 01 00 00    	jne    801029e8 <end_op+0x144>
    panic("log.committing");
  if(log.outstanding == 0){
801028d6:	85 db                	test   %ebx,%ebx
801028d8:	0f 85 e6 00 00 00    	jne    801029c4 <end_op+0x120>
    do_commit = 1;
    log.committing = 1;
801028de:	c7 05 a0 30 11 80 01 	movl   $0x1,0x801130a0
801028e5:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
801028e8:	83 ec 0c             	sub    $0xc,%esp
801028eb:	68 60 30 11 80       	push   $0x80113060
801028f0:	e8 ef 17 00 00       	call   801040e4 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
801028f5:	83 c4 10             	add    $0x10,%esp
801028f8:	8b 0d a8 30 11 80    	mov    0x801130a8,%ecx
801028fe:	85 c9                	test   %ecx,%ecx
80102900:	7f 3a                	jg     8010293c <end_op+0x98>
    acquire(&log.lock);
80102902:	83 ec 0c             	sub    $0xc,%esp
80102905:	68 60 30 11 80       	push   $0x80113060
8010290a:	e8 3d 17 00 00       	call   8010404c <acquire>
    log.committing = 0;
8010290f:	c7 05 a0 30 11 80 00 	movl   $0x0,0x801130a0
80102916:	00 00 00 
    wakeup(&log);
80102919:	c7 04 24 60 30 11 80 	movl   $0x80113060,(%esp)
80102920:	e8 77 11 00 00       	call   80103a9c <wakeup>
    release(&log.lock);
80102925:	c7 04 24 60 30 11 80 	movl   $0x80113060,(%esp)
8010292c:	e8 b3 17 00 00       	call   801040e4 <release>
80102931:	83 c4 10             	add    $0x10,%esp
}
80102934:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102937:	5b                   	pop    %ebx
80102938:	5e                   	pop    %esi
80102939:	5f                   	pop    %edi
8010293a:	5d                   	pop    %ebp
8010293b:	c3                   	ret    
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010293c:	83 ec 08             	sub    $0x8,%esp
8010293f:	a1 94 30 11 80       	mov    0x80113094,%eax
80102944:	01 d8                	add    %ebx,%eax
80102946:	40                   	inc    %eax
80102947:	50                   	push   %eax
80102948:	ff 35 a4 30 11 80    	pushl  0x801130a4
8010294e:	e8 61 d7 ff ff       	call   801000b4 <bread>
80102953:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102955:	58                   	pop    %eax
80102956:	5a                   	pop    %edx
80102957:	ff 34 9d ac 30 11 80 	pushl  -0x7feecf54(,%ebx,4)
8010295e:	ff 35 a4 30 11 80    	pushl  0x801130a4
80102964:	e8 4b d7 ff ff       	call   801000b4 <bread>
80102969:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
8010296b:	83 c4 0c             	add    $0xc,%esp
8010296e:	68 00 02 00 00       	push   $0x200
80102973:	8d 40 5c             	lea    0x5c(%eax),%eax
80102976:	50                   	push   %eax
80102977:	8d 46 5c             	lea    0x5c(%esi),%eax
8010297a:	50                   	push   %eax
8010297b:	e8 30 18 00 00       	call   801041b0 <memmove>
    bwrite(to);  // write the log
80102980:	89 34 24             	mov    %esi,(%esp)
80102983:	e8 00 d8 ff ff       	call   80100188 <bwrite>
    brelse(from);
80102988:	89 3c 24             	mov    %edi,(%esp)
8010298b:	e8 30 d8 ff ff       	call   801001c0 <brelse>
    brelse(to);
80102990:	89 34 24             	mov    %esi,(%esp)
80102993:	e8 28 d8 ff ff       	call   801001c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102998:	43                   	inc    %ebx
80102999:	83 c4 10             	add    $0x10,%esp
8010299c:	3b 1d a8 30 11 80    	cmp    0x801130a8,%ebx
801029a2:	7c 98                	jl     8010293c <end_op+0x98>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
801029a4:	e8 ab fd ff ff       	call   80102754 <write_head>
    install_trans(); // Now install writes to home locations
801029a9:	e8 1a fd ff ff       	call   801026c8 <install_trans>
    log.lh.n = 0;
801029ae:	c7 05 a8 30 11 80 00 	movl   $0x0,0x801130a8
801029b5:	00 00 00 
    write_head();    // Erase the transaction from the log
801029b8:	e8 97 fd ff ff       	call   80102754 <write_head>
801029bd:	e9 40 ff ff ff       	jmp    80102902 <end_op+0x5e>
801029c2:	66 90                	xchg   %ax,%ax
    wakeup(&log);
801029c4:	83 ec 0c             	sub    $0xc,%esp
801029c7:	68 60 30 11 80       	push   $0x80113060
801029cc:	e8 cb 10 00 00       	call   80103a9c <wakeup>
  release(&log.lock);
801029d1:	c7 04 24 60 30 11 80 	movl   $0x80113060,(%esp)
801029d8:	e8 07 17 00 00       	call   801040e4 <release>
801029dd:	83 c4 10             	add    $0x10,%esp
}
801029e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801029e3:	5b                   	pop    %ebx
801029e4:	5e                   	pop    %esi
801029e5:	5f                   	pop    %edi
801029e6:	5d                   	pop    %ebp
801029e7:	c3                   	ret    
    panic("log.committing");
801029e8:	83 ec 0c             	sub    $0xc,%esp
801029eb:	68 44 6c 10 80       	push   $0x80106c44
801029f0:	e8 4b d9 ff ff       	call   80100340 <panic>
801029f5:	8d 76 00             	lea    0x0(%esi),%esi

801029f8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801029f8:	55                   	push   %ebp
801029f9:	89 e5                	mov    %esp,%ebp
801029fb:	53                   	push   %ebx
801029fc:	52                   	push   %edx
801029fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102a00:	8b 15 a8 30 11 80    	mov    0x801130a8,%edx
80102a06:	83 fa 1d             	cmp    $0x1d,%edx
80102a09:	7f 79                	jg     80102a84 <log_write+0x8c>
80102a0b:	a1 98 30 11 80       	mov    0x80113098,%eax
80102a10:	48                   	dec    %eax
80102a11:	39 c2                	cmp    %eax,%edx
80102a13:	7d 6f                	jge    80102a84 <log_write+0x8c>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102a15:	a1 9c 30 11 80       	mov    0x8011309c,%eax
80102a1a:	85 c0                	test   %eax,%eax
80102a1c:	7e 73                	jle    80102a91 <log_write+0x99>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102a1e:	83 ec 0c             	sub    $0xc,%esp
80102a21:	68 60 30 11 80       	push   $0x80113060
80102a26:	e8 21 16 00 00       	call   8010404c <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102a2b:	8b 15 a8 30 11 80    	mov    0x801130a8,%edx
80102a31:	83 c4 10             	add    $0x10,%esp
80102a34:	85 d2                	test   %edx,%edx
80102a36:	7e 40                	jle    80102a78 <log_write+0x80>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102a38:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
80102a3b:	31 c0                	xor    %eax,%eax
80102a3d:	eb 06                	jmp    80102a45 <log_write+0x4d>
80102a3f:	90                   	nop
80102a40:	40                   	inc    %eax
80102a41:	39 c2                	cmp    %eax,%edx
80102a43:	74 23                	je     80102a68 <log_write+0x70>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102a45:	39 0c 85 ac 30 11 80 	cmp    %ecx,-0x7feecf54(,%eax,4)
80102a4c:	75 f2                	jne    80102a40 <log_write+0x48>
      break;
  }
  log.lh.block[i] = b->blockno;
80102a4e:	89 0c 85 ac 30 11 80 	mov    %ecx,-0x7feecf54(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102a55:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102a58:	c7 45 08 60 30 11 80 	movl   $0x80113060,0x8(%ebp)
}
80102a5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a62:	c9                   	leave  
  release(&log.lock);
80102a63:	e9 7c 16 00 00       	jmp    801040e4 <release>
  log.lh.block[i] = b->blockno;
80102a68:	89 0c 95 ac 30 11 80 	mov    %ecx,-0x7feecf54(,%edx,4)
    log.lh.n++;
80102a6f:	42                   	inc    %edx
80102a70:	89 15 a8 30 11 80    	mov    %edx,0x801130a8
80102a76:	eb dd                	jmp    80102a55 <log_write+0x5d>
  log.lh.block[i] = b->blockno;
80102a78:	8b 43 08             	mov    0x8(%ebx),%eax
80102a7b:	a3 ac 30 11 80       	mov    %eax,0x801130ac
  if (i == log.lh.n)
80102a80:	75 d3                	jne    80102a55 <log_write+0x5d>
80102a82:	eb eb                	jmp    80102a6f <log_write+0x77>
    panic("too big a transaction");
80102a84:	83 ec 0c             	sub    $0xc,%esp
80102a87:	68 53 6c 10 80       	push   $0x80106c53
80102a8c:	e8 af d8 ff ff       	call   80100340 <panic>
    panic("log_write outside of trans");
80102a91:	83 ec 0c             	sub    $0xc,%esp
80102a94:	68 69 6c 10 80       	push   $0x80106c69
80102a99:	e8 a2 d8 ff ff       	call   80100340 <panic>
80102a9e:	66 90                	xchg   %ax,%ax

80102aa0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80102aa0:	55                   	push   %ebp
80102aa1:	89 e5                	mov    %esp,%ebp
80102aa3:	53                   	push   %ebx
80102aa4:	50                   	push   %eax
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102aa5:	e8 82 08 00 00       	call   8010332c <cpuid>
80102aaa:	89 c3                	mov    %eax,%ebx
80102aac:	e8 7b 08 00 00       	call   8010332c <cpuid>
80102ab1:	52                   	push   %edx
80102ab2:	53                   	push   %ebx
80102ab3:	50                   	push   %eax
80102ab4:	68 84 6c 10 80       	push   $0x80106c84
80102ab9:	e8 62 db ff ff       	call   80100620 <cprintf>
  idtinit();       // load idt register
80102abe:	e8 61 26 00 00       	call   80105124 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102ac3:	e8 00 08 00 00       	call   801032c8 <mycpu>
80102ac8:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102aca:	b8 01 00 00 00       	mov    $0x1,%eax
80102acf:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102ad6:	e8 39 0b 00 00       	call   80103614 <scheduler>
80102adb:	90                   	nop

80102adc <mpenter>:
{
80102adc:	55                   	push   %ebp
80102add:	89 e5                	mov    %esp,%ebp
80102adf:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102ae2:	e8 6d 36 00 00       	call   80106154 <switchkvm>
  seginit();
80102ae7:	e8 e4 35 00 00       	call   801060d0 <seginit>
  lapicinit();
80102aec:	e8 87 f8 ff ff       	call   80102378 <lapicinit>
  mpmain();
80102af1:	e8 aa ff ff ff       	call   80102aa0 <mpmain>
80102af6:	66 90                	xchg   %ax,%ax

80102af8 <main>:
{
80102af8:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102afc:	83 e4 f0             	and    $0xfffffff0,%esp
80102aff:	ff 71 fc             	pushl  -0x4(%ecx)
80102b02:	55                   	push   %ebp
80102b03:	89 e5                	mov    %esp,%ebp
80102b05:	53                   	push   %ebx
80102b06:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102b07:	83 ec 08             	sub    $0x8,%esp
80102b0a:	68 00 00 40 80       	push   $0x80400000
80102b0f:	68 88 5f 11 80       	push   $0x80115f88
80102b14:	e8 63 f6 ff ff       	call   8010217c <kinit1>
  kvmalloc();      // kernel page table
80102b19:	e8 9a 3a 00 00       	call   801065b8 <kvmalloc>
  mpinit();        // detect other processors
80102b1e:	e8 61 01 00 00       	call   80102c84 <mpinit>
  lapicinit();     // interrupt controller
80102b23:	e8 50 f8 ff ff       	call   80102378 <lapicinit>
  seginit();       // segment descriptors
80102b28:	e8 a3 35 00 00       	call   801060d0 <seginit>
  picinit();       // disable pic
80102b2d:	e8 f2 02 00 00       	call   80102e24 <picinit>
  ioapicinit();    // another interrupt controller
80102b32:	e8 99 f4 ff ff       	call   80101fd0 <ioapicinit>
  consoleinit();   // console hardware
80102b37:	e8 24 de ff ff       	call   80100960 <consoleinit>
  uartinit();      // serial port
80102b3c:	e8 af 28 00 00       	call   801053f0 <uartinit>
  pinit();         // process table
80102b41:	e8 66 07 00 00       	call   801032ac <pinit>
  tvinit();        // trap vectors
80102b46:	e8 6d 25 00 00       	call   801050b8 <tvinit>
  binit();         // buffer cache
80102b4b:	e8 e4 d4 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80102b50:	e8 87 e1 ff ff       	call   80100cdc <fileinit>
  ideinit();       // disk 
80102b55:	e8 9a f2 ff ff       	call   80101df4 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102b5a:	83 c4 0c             	add    $0xc,%esp
80102b5d:	68 8a 00 00 00       	push   $0x8a
80102b62:	68 8c a4 10 80       	push   $0x8010a48c
80102b67:	68 00 70 00 80       	push   $0x80007000
80102b6c:	e8 3f 16 00 00       	call   801041b0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102b71:	8b 15 e0 36 11 80    	mov    0x801136e0,%edx
80102b77:	8d 04 92             	lea    (%edx,%edx,4),%eax
80102b7a:	01 c0                	add    %eax,%eax
80102b7c:	01 d0                	add    %edx,%eax
80102b7e:	c1 e0 04             	shl    $0x4,%eax
80102b81:	05 60 31 11 80       	add    $0x80113160,%eax
80102b86:	83 c4 10             	add    $0x10,%esp
80102b89:	3d 60 31 11 80       	cmp    $0x80113160,%eax
80102b8e:	76 74                	jbe    80102c04 <main+0x10c>
80102b90:	bb 60 31 11 80       	mov    $0x80113160,%ebx
80102b95:	eb 20                	jmp    80102bb7 <main+0xbf>
80102b97:	90                   	nop
80102b98:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102b9e:	8b 15 e0 36 11 80    	mov    0x801136e0,%edx
80102ba4:	8d 04 92             	lea    (%edx,%edx,4),%eax
80102ba7:	01 c0                	add    %eax,%eax
80102ba9:	01 d0                	add    %edx,%eax
80102bab:	c1 e0 04             	shl    $0x4,%eax
80102bae:	05 60 31 11 80       	add    $0x80113160,%eax
80102bb3:	39 c3                	cmp    %eax,%ebx
80102bb5:	73 4d                	jae    80102c04 <main+0x10c>
    if(c == mycpu())  // We've started already.
80102bb7:	e8 0c 07 00 00       	call   801032c8 <mycpu>
80102bbc:	39 c3                	cmp    %eax,%ebx
80102bbe:	74 d8                	je     80102b98 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102bc0:	e8 6f f6 ff ff       	call   80102234 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102bc5:	05 00 10 00 00       	add    $0x1000,%eax
80102bca:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102bcf:	c7 05 f8 6f 00 80 dc 	movl   $0x80102adc,0x80006ff8
80102bd6:	2a 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102bd9:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102be0:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102be3:	83 ec 08             	sub    $0x8,%esp
80102be6:	68 00 70 00 00       	push   $0x7000
80102beb:	0f b6 03             	movzbl (%ebx),%eax
80102bee:	50                   	push   %eax
80102bef:	e8 98 f8 ff ff       	call   8010248c <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102bf4:	83 c4 10             	add    $0x10,%esp
80102bf7:	90                   	nop
80102bf8:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102bfe:	85 c0                	test   %eax,%eax
80102c00:	74 f6                	je     80102bf8 <main+0x100>
80102c02:	eb 94                	jmp    80102b98 <main+0xa0>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102c04:	83 ec 08             	sub    $0x8,%esp
80102c07:	68 00 00 00 8e       	push   $0x8e000000
80102c0c:	68 00 00 40 80       	push   $0x80400000
80102c11:	e8 ca f5 ff ff       	call   801021e0 <kinit2>
  userinit();      // first user process
80102c16:	e8 69 07 00 00       	call   80103384 <userinit>
  mpmain();        // finish this processor's setup
80102c1b:	e8 80 fe ff ff       	call   80102aa0 <mpmain>

80102c20 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102c20:	55                   	push   %ebp
80102c21:	89 e5                	mov    %esp,%ebp
80102c23:	57                   	push   %edi
80102c24:	56                   	push   %esi
80102c25:	53                   	push   %ebx
80102c26:	83 ec 0c             	sub    $0xc,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80102c29:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
  e = addr+len;
80102c2f:	8d 9c 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%ebx
  for(p = addr; p < e; p += sizeof(struct mp))
80102c36:	39 de                	cmp    %ebx,%esi
80102c38:	72 0b                	jb     80102c45 <mpsearch1+0x25>
80102c3a:	eb 3c                	jmp    80102c78 <mpsearch1+0x58>
80102c3c:	8d 7e 10             	lea    0x10(%esi),%edi
80102c3f:	89 fe                	mov    %edi,%esi
80102c41:	39 fb                	cmp    %edi,%ebx
80102c43:	76 33                	jbe    80102c78 <mpsearch1+0x58>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102c45:	50                   	push   %eax
80102c46:	6a 04                	push   $0x4
80102c48:	68 98 6c 10 80       	push   $0x80106c98
80102c4d:	56                   	push   %esi
80102c4e:	e8 25 15 00 00       	call   80104178 <memcmp>
80102c53:	83 c4 10             	add    $0x10,%esp
80102c56:	85 c0                	test   %eax,%eax
80102c58:	75 e2                	jne    80102c3c <mpsearch1+0x1c>
80102c5a:	89 f2                	mov    %esi,%edx
80102c5c:	8d 7e 10             	lea    0x10(%esi),%edi
80102c5f:	90                   	nop
    sum += addr[i];
80102c60:	0f b6 0a             	movzbl (%edx),%ecx
80102c63:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
80102c65:	42                   	inc    %edx
80102c66:	39 fa                	cmp    %edi,%edx
80102c68:	75 f6                	jne    80102c60 <mpsearch1+0x40>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102c6a:	84 c0                	test   %al,%al
80102c6c:	75 d1                	jne    80102c3f <mpsearch1+0x1f>
      return (struct mp*)p;
  return 0;
}
80102c6e:	89 f0                	mov    %esi,%eax
80102c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c73:	5b                   	pop    %ebx
80102c74:	5e                   	pop    %esi
80102c75:	5f                   	pop    %edi
80102c76:	5d                   	pop    %ebp
80102c77:	c3                   	ret    
  return 0;
80102c78:	31 f6                	xor    %esi,%esi
}
80102c7a:	89 f0                	mov    %esi,%eax
80102c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c7f:	5b                   	pop    %ebx
80102c80:	5e                   	pop    %esi
80102c81:	5f                   	pop    %edi
80102c82:	5d                   	pop    %ebp
80102c83:	c3                   	ret    

80102c84 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80102c84:	55                   	push   %ebp
80102c85:	89 e5                	mov    %esp,%ebp
80102c87:	57                   	push   %edi
80102c88:	56                   	push   %esi
80102c89:	53                   	push   %ebx
80102c8a:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102c8d:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102c94:	c1 e0 08             	shl    $0x8,%eax
80102c97:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102c9e:	09 d0                	or     %edx,%eax
80102ca0:	c1 e0 04             	shl    $0x4,%eax
80102ca3:	75 1b                	jne    80102cc0 <mpinit+0x3c>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102ca5:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102cac:	c1 e0 08             	shl    $0x8,%eax
80102caf:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102cb6:	09 d0                	or     %edx,%eax
80102cb8:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102cbb:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
80102cc0:	ba 00 04 00 00       	mov    $0x400,%edx
80102cc5:	e8 56 ff ff ff       	call   80102c20 <mpsearch1>
80102cca:	89 c3                	mov    %eax,%ebx
80102ccc:	85 c0                	test   %eax,%eax
80102cce:	0f 84 18 01 00 00    	je     80102dec <mpinit+0x168>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102cd4:	8b 73 04             	mov    0x4(%ebx),%esi
80102cd7:	85 f6                	test   %esi,%esi
80102cd9:	0f 84 29 01 00 00    	je     80102e08 <mpinit+0x184>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102cdf:	8d be 00 00 00 80    	lea    -0x80000000(%esi),%edi
  if(memcmp(conf, "PCMP", 4) != 0)
80102ce5:	50                   	push   %eax
80102ce6:	6a 04                	push   $0x4
80102ce8:	68 9d 6c 10 80       	push   $0x80106c9d
80102ced:	57                   	push   %edi
80102cee:	e8 85 14 00 00       	call   80104178 <memcmp>
80102cf3:	83 c4 10             	add    $0x10,%esp
80102cf6:	85 c0                	test   %eax,%eax
80102cf8:	0f 85 0a 01 00 00    	jne    80102e08 <mpinit+0x184>
  if(conf->version != 1 && conf->version != 4)
80102cfe:	8a 86 06 00 00 80    	mov    -0x7ffffffa(%esi),%al
80102d04:	3c 01                	cmp    $0x1,%al
80102d06:	74 08                	je     80102d10 <mpinit+0x8c>
80102d08:	3c 04                	cmp    $0x4,%al
80102d0a:	0f 85 f8 00 00 00    	jne    80102e08 <mpinit+0x184>
  if(sum((uchar*)conf, conf->length) != 0)
80102d10:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
  for(i=0; i<len; i++)
80102d17:	66 85 d2             	test   %dx,%dx
80102d1a:	74 1f                	je     80102d3b <mpinit+0xb7>
80102d1c:	89 f8                	mov    %edi,%eax
80102d1e:	8d 0c 17             	lea    (%edi,%edx,1),%ecx
80102d21:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  sum = 0;
80102d24:	31 d2                	xor    %edx,%edx
80102d26:	66 90                	xchg   %ax,%ax
    sum += addr[i];
80102d28:	0f b6 08             	movzbl (%eax),%ecx
80102d2b:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
80102d2d:	40                   	inc    %eax
80102d2e:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80102d31:	75 f5                	jne    80102d28 <mpinit+0xa4>
  if(sum((uchar*)conf, conf->length) != 0)
80102d33:	84 d2                	test   %dl,%dl
80102d35:	0f 85 cd 00 00 00    	jne    80102e08 <mpinit+0x184>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102d3b:	8b 86 24 00 00 80    	mov    -0x7fffffdc(%esi),%eax
80102d41:	a3 5c 30 11 80       	mov    %eax,0x8011305c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d46:	8d 96 2c 00 00 80    	lea    -0x7fffffd4(%esi),%edx
80102d4c:	0f b7 86 04 00 00 80 	movzwl -0x7ffffffc(%esi),%eax
80102d53:	01 c7                	add    %eax,%edi
  ismp = 1;
80102d55:	b9 01 00 00 00       	mov    $0x1,%ecx
80102d5a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80102d5d:	8d 76 00             	lea    0x0(%esi),%esi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d60:	39 d7                	cmp    %edx,%edi
80102d62:	76 13                	jbe    80102d77 <mpinit+0xf3>
    switch(*p){
80102d64:	8a 02                	mov    (%edx),%al
80102d66:	3c 02                	cmp    $0x2,%al
80102d68:	74 46                	je     80102db0 <mpinit+0x12c>
80102d6a:	77 38                	ja     80102da4 <mpinit+0x120>
80102d6c:	84 c0                	test   %al,%al
80102d6e:	74 50                	je     80102dc0 <mpinit+0x13c>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102d70:	83 c2 08             	add    $0x8,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d73:	39 d7                	cmp    %edx,%edi
80102d75:	77 ed                	ja     80102d64 <mpinit+0xe0>
80102d77:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102d7a:	85 c9                	test   %ecx,%ecx
80102d7c:	0f 84 93 00 00 00    	je     80102e15 <mpinit+0x191>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102d82:	80 7b 0c 00          	cmpb   $0x0,0xc(%ebx)
80102d86:	74 12                	je     80102d9a <mpinit+0x116>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d88:	b0 70                	mov    $0x70,%al
80102d8a:	ba 22 00 00 00       	mov    $0x22,%edx
80102d8f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d90:	ba 23 00 00 00       	mov    $0x23,%edx
80102d95:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102d96:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d99:	ee                   	out    %al,(%dx)
  }
}
80102d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d9d:	5b                   	pop    %ebx
80102d9e:	5e                   	pop    %esi
80102d9f:	5f                   	pop    %edi
80102da0:	5d                   	pop    %ebp
80102da1:	c3                   	ret    
80102da2:	66 90                	xchg   %ax,%ax
    switch(*p){
80102da4:	83 e8 03             	sub    $0x3,%eax
80102da7:	3c 01                	cmp    $0x1,%al
80102da9:	76 c5                	jbe    80102d70 <mpinit+0xec>
80102dab:	31 c9                	xor    %ecx,%ecx
80102dad:	eb b1                	jmp    80102d60 <mpinit+0xdc>
80102daf:	90                   	nop
      ioapicid = ioapic->apicno;
80102db0:	8a 42 01             	mov    0x1(%edx),%al
80102db3:	a2 40 31 11 80       	mov    %al,0x80113140
      p += sizeof(struct mpioapic);
80102db8:	83 c2 08             	add    $0x8,%edx
      continue;
80102dbb:	eb a3                	jmp    80102d60 <mpinit+0xdc>
80102dbd:	8d 76 00             	lea    0x0(%esi),%esi
      if(ncpu < NCPU) {
80102dc0:	a1 e0 36 11 80       	mov    0x801136e0,%eax
80102dc5:	83 f8 07             	cmp    $0x7,%eax
80102dc8:	7f 19                	jg     80102de3 <mpinit+0x15f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102dca:	8d 34 80             	lea    (%eax,%eax,4),%esi
80102dcd:	01 f6                	add    %esi,%esi
80102dcf:	01 c6                	add    %eax,%esi
80102dd1:	c1 e6 04             	shl    $0x4,%esi
80102dd4:	8a 5a 01             	mov    0x1(%edx),%bl
80102dd7:	88 9e 60 31 11 80    	mov    %bl,-0x7feecea0(%esi)
        ncpu++;
80102ddd:	40                   	inc    %eax
80102dde:	a3 e0 36 11 80       	mov    %eax,0x801136e0
      p += sizeof(struct mpproc);
80102de3:	83 c2 14             	add    $0x14,%edx
      continue;
80102de6:	e9 75 ff ff ff       	jmp    80102d60 <mpinit+0xdc>
80102deb:	90                   	nop
  return mpsearch1(0xF0000, 0x10000);
80102dec:	ba 00 00 01 00       	mov    $0x10000,%edx
80102df1:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102df6:	e8 25 fe ff ff       	call   80102c20 <mpsearch1>
80102dfb:	89 c3                	mov    %eax,%ebx
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102dfd:	85 c0                	test   %eax,%eax
80102dff:	0f 85 cf fe ff ff    	jne    80102cd4 <mpinit+0x50>
80102e05:	8d 76 00             	lea    0x0(%esi),%esi
    panic("Expect to run on an SMP");
80102e08:	83 ec 0c             	sub    $0xc,%esp
80102e0b:	68 a2 6c 10 80       	push   $0x80106ca2
80102e10:	e8 2b d5 ff ff       	call   80100340 <panic>
    panic("Didn't find a suitable machine");
80102e15:	83 ec 0c             	sub    $0xc,%esp
80102e18:	68 bc 6c 10 80       	push   $0x80106cbc
80102e1d:	e8 1e d5 ff ff       	call   80100340 <panic>
80102e22:	66 90                	xchg   %ax,%ax

80102e24 <picinit>:
80102e24:	b0 ff                	mov    $0xff,%al
80102e26:	ba 21 00 00 00       	mov    $0x21,%edx
80102e2b:	ee                   	out    %al,(%dx)
80102e2c:	ba a1 00 00 00       	mov    $0xa1,%edx
80102e31:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102e32:	c3                   	ret    
80102e33:	90                   	nop

80102e34 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102e34:	55                   	push   %ebp
80102e35:	89 e5                	mov    %esp,%ebp
80102e37:	57                   	push   %edi
80102e38:	56                   	push   %esi
80102e39:	53                   	push   %ebx
80102e3a:	83 ec 0c             	sub    $0xc,%esp
80102e3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e40:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102e43:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102e49:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102e4f:	e8 a4 de ff ff       	call   80100cf8 <filealloc>
80102e54:	89 03                	mov    %eax,(%ebx)
80102e56:	85 c0                	test   %eax,%eax
80102e58:	0f 84 a8 00 00 00    	je     80102f06 <pipealloc+0xd2>
80102e5e:	e8 95 de ff ff       	call   80100cf8 <filealloc>
80102e63:	89 06                	mov    %eax,(%esi)
80102e65:	85 c0                	test   %eax,%eax
80102e67:	0f 84 87 00 00 00    	je     80102ef4 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102e6d:	e8 c2 f3 ff ff       	call   80102234 <kalloc>
80102e72:	89 c7                	mov    %eax,%edi
80102e74:	85 c0                	test   %eax,%eax
80102e76:	0f 84 ac 00 00 00    	je     80102f28 <pipealloc+0xf4>
    goto bad;
  p->readopen = 1;
80102e7c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102e83:	00 00 00 
  p->writeopen = 1;
80102e86:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102e8d:	00 00 00 
  p->nwrite = 0;
80102e90:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102e97:	00 00 00 
  p->nread = 0;
80102e9a:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102ea1:	00 00 00 
  initlock(&p->lock, "pipe");
80102ea4:	83 ec 08             	sub    $0x8,%esp
80102ea7:	68 db 6c 10 80       	push   $0x80106cdb
80102eac:	50                   	push   %eax
80102ead:	e8 5a 10 00 00       	call   80103f0c <initlock>
  (*f0)->type = FD_PIPE;
80102eb2:	8b 03                	mov    (%ebx),%eax
80102eb4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102eba:	8b 03                	mov    (%ebx),%eax
80102ebc:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102ec0:	8b 03                	mov    (%ebx),%eax
80102ec2:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102ec6:	8b 03                	mov    (%ebx),%eax
80102ec8:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102ecb:	8b 06                	mov    (%esi),%eax
80102ecd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102ed3:	8b 06                	mov    (%esi),%eax
80102ed5:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102ed9:	8b 06                	mov    (%esi),%eax
80102edb:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102edf:	8b 06                	mov    (%esi),%eax
80102ee1:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102ee4:	83 c4 10             	add    $0x10,%esp
80102ee7:	31 c0                	xor    %eax,%eax
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
80102ee9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102eec:	5b                   	pop    %ebx
80102eed:	5e                   	pop    %esi
80102eee:	5f                   	pop    %edi
80102eef:	5d                   	pop    %ebp
80102ef0:	c3                   	ret    
80102ef1:	8d 76 00             	lea    0x0(%esi),%esi
  if(*f0)
80102ef4:	8b 03                	mov    (%ebx),%eax
80102ef6:	85 c0                	test   %eax,%eax
80102ef8:	74 1e                	je     80102f18 <pipealloc+0xe4>
    fileclose(*f0);
80102efa:	83 ec 0c             	sub    $0xc,%esp
80102efd:	50                   	push   %eax
80102efe:	e8 99 de ff ff       	call   80100d9c <fileclose>
80102f03:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102f06:	8b 06                	mov    (%esi),%eax
80102f08:	85 c0                	test   %eax,%eax
80102f0a:	74 0c                	je     80102f18 <pipealloc+0xe4>
    fileclose(*f1);
80102f0c:	83 ec 0c             	sub    $0xc,%esp
80102f0f:	50                   	push   %eax
80102f10:	e8 87 de ff ff       	call   80100d9c <fileclose>
80102f15:	83 c4 10             	add    $0x10,%esp
  return -1;
80102f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f20:	5b                   	pop    %ebx
80102f21:	5e                   	pop    %esi
80102f22:	5f                   	pop    %edi
80102f23:	5d                   	pop    %ebp
80102f24:	c3                   	ret    
80102f25:	8d 76 00             	lea    0x0(%esi),%esi
  if(*f0)
80102f28:	8b 03                	mov    (%ebx),%eax
80102f2a:	85 c0                	test   %eax,%eax
80102f2c:	75 cc                	jne    80102efa <pipealloc+0xc6>
80102f2e:	eb d6                	jmp    80102f06 <pipealloc+0xd2>

80102f30 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102f30:	55                   	push   %ebp
80102f31:	89 e5                	mov    %esp,%ebp
80102f33:	56                   	push   %esi
80102f34:	53                   	push   %ebx
80102f35:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102f38:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
80102f3b:	83 ec 0c             	sub    $0xc,%esp
80102f3e:	53                   	push   %ebx
80102f3f:	e8 08 11 00 00       	call   8010404c <acquire>
  if(writable){
80102f44:	83 c4 10             	add    $0x10,%esp
80102f47:	85 f6                	test   %esi,%esi
80102f49:	74 41                	je     80102f8c <pipeclose+0x5c>
    p->writeopen = 0;
80102f4b:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102f52:	00 00 00 
    wakeup(&p->nread);
80102f55:	83 ec 0c             	sub    $0xc,%esp
80102f58:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f5e:	50                   	push   %eax
80102f5f:	e8 38 0b 00 00       	call   80103a9c <wakeup>
80102f64:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102f67:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
80102f6d:	85 d2                	test   %edx,%edx
80102f6f:	75 0a                	jne    80102f7b <pipeclose+0x4b>
80102f71:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80102f77:	85 c0                	test   %eax,%eax
80102f79:	74 31                	je     80102fac <pipeclose+0x7c>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102f7b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80102f7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102f81:	5b                   	pop    %ebx
80102f82:	5e                   	pop    %esi
80102f83:	5d                   	pop    %ebp
    release(&p->lock);
80102f84:	e9 5b 11 00 00       	jmp    801040e4 <release>
80102f89:	8d 76 00             	lea    0x0(%esi),%esi
    p->readopen = 0;
80102f8c:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102f93:	00 00 00 
    wakeup(&p->nwrite);
80102f96:	83 ec 0c             	sub    $0xc,%esp
80102f99:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f9f:	50                   	push   %eax
80102fa0:	e8 f7 0a 00 00       	call   80103a9c <wakeup>
80102fa5:	83 c4 10             	add    $0x10,%esp
80102fa8:	eb bd                	jmp    80102f67 <pipeclose+0x37>
80102faa:	66 90                	xchg   %ax,%ax
    release(&p->lock);
80102fac:	83 ec 0c             	sub    $0xc,%esp
80102faf:	53                   	push   %ebx
80102fb0:	e8 2f 11 00 00       	call   801040e4 <release>
    kfree((char*)p);
80102fb5:	83 c4 10             	add    $0x10,%esp
80102fb8:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80102fbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102fbe:	5b                   	pop    %ebx
80102fbf:	5e                   	pop    %esi
80102fc0:	5d                   	pop    %ebp
    kfree((char*)p);
80102fc1:	e9 de f0 ff ff       	jmp    801020a4 <kfree>
80102fc6:	66 90                	xchg   %ax,%ax

80102fc8 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102fc8:	55                   	push   %ebp
80102fc9:	89 e5                	mov    %esp,%ebp
80102fcb:	57                   	push   %edi
80102fcc:	56                   	push   %esi
80102fcd:	53                   	push   %ebx
80102fce:	83 ec 28             	sub    $0x28,%esp
80102fd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102fd4:	53                   	push   %ebx
80102fd5:	e8 72 10 00 00       	call   8010404c <acquire>
  for(i = 0; i < n; i++){
80102fda:	83 c4 10             	add    $0x10,%esp
80102fdd:	8b 45 10             	mov    0x10(%ebp),%eax
80102fe0:	85 c0                	test   %eax,%eax
80102fe2:	0f 8e b1 00 00 00    	jle    80103099 <pipewrite+0xd1>
80102fe8:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102ff1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80102ff4:	03 4d 10             	add    0x10(%ebp),%ecx
80102ff7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102ffa:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103000:	8b 8b 34 02 00 00    	mov    0x234(%ebx),%ecx
80103006:	8d 91 00 02 00 00    	lea    0x200(%ecx),%edx
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010300c:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103012:	39 d0                	cmp    %edx,%eax
80103014:	74 38                	je     8010304e <pipewrite+0x86>
80103016:	eb 59                	jmp    80103071 <pipewrite+0xa9>
      if(p->readopen == 0 || myproc()->killed){
80103018:	e8 43 03 00 00       	call   80103360 <myproc>
8010301d:	8b 48 24             	mov    0x24(%eax),%ecx
80103020:	85 c9                	test   %ecx,%ecx
80103022:	75 34                	jne    80103058 <pipewrite+0x90>
      wakeup(&p->nread);
80103024:	83 ec 0c             	sub    $0xc,%esp
80103027:	57                   	push   %edi
80103028:	e8 6f 0a 00 00       	call   80103a9c <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010302d:	58                   	pop    %eax
8010302e:	5a                   	pop    %edx
8010302f:	53                   	push   %ebx
80103030:	56                   	push   %esi
80103031:	e8 ba 08 00 00       	call   801038f0 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103036:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
8010303c:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103042:	05 00 02 00 00       	add    $0x200,%eax
80103047:	83 c4 10             	add    $0x10,%esp
8010304a:	39 c2                	cmp    %eax,%edx
8010304c:	75 26                	jne    80103074 <pipewrite+0xac>
      if(p->readopen == 0 || myproc()->killed){
8010304e:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103054:	85 c0                	test   %eax,%eax
80103056:	75 c0                	jne    80103018 <pipewrite+0x50>
        release(&p->lock);
80103058:	83 ec 0c             	sub    $0xc,%esp
8010305b:	53                   	push   %ebx
8010305c:	e8 83 10 00 00       	call   801040e4 <release>
        return -1;
80103061:	83 c4 10             	add    $0x10,%esp
80103064:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103069:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010306c:	5b                   	pop    %ebx
8010306d:	5e                   	pop    %esi
8010306e:	5f                   	pop    %edi
8010306f:	5d                   	pop    %ebp
80103070:	c3                   	ret    
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103071:	89 c2                	mov    %eax,%edx
80103073:	90                   	nop
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103074:	8d 42 01             	lea    0x1(%edx),%eax
80103077:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
8010307d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80103080:	8a 0e                	mov    (%esi),%cl
80103082:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103088:	88 4c 13 34          	mov    %cl,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
8010308c:	46                   	inc    %esi
8010308d:	89 75 e4             	mov    %esi,-0x1c(%ebp)
80103090:	3b 75 e0             	cmp    -0x20(%ebp),%esi
80103093:	0f 85 67 ff ff ff    	jne    80103000 <pipewrite+0x38>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103099:	83 ec 0c             	sub    $0xc,%esp
8010309c:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030a2:	50                   	push   %eax
801030a3:	e8 f4 09 00 00       	call   80103a9c <wakeup>
  release(&p->lock);
801030a8:	89 1c 24             	mov    %ebx,(%esp)
801030ab:	e8 34 10 00 00       	call   801040e4 <release>
  return n;
801030b0:	83 c4 10             	add    $0x10,%esp
801030b3:	8b 45 10             	mov    0x10(%ebp),%eax
801030b6:	eb b1                	jmp    80103069 <pipewrite+0xa1>

801030b8 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801030b8:	55                   	push   %ebp
801030b9:	89 e5                	mov    %esp,%ebp
801030bb:	57                   	push   %edi
801030bc:	56                   	push   %esi
801030bd:	53                   	push   %ebx
801030be:	83 ec 18             	sub    $0x18,%esp
801030c1:	8b 75 08             	mov    0x8(%ebp),%esi
801030c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801030c7:	56                   	push   %esi
801030c8:	e8 7f 0f 00 00       	call   8010404c <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801030cd:	83 c4 10             	add    $0x10,%esp
801030d0:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
801030d6:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
801030dc:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
801030e2:	74 2f                	je     80103113 <piperead+0x5b>
801030e4:	eb 37                	jmp    8010311d <piperead+0x65>
801030e6:	66 90                	xchg   %ax,%ax
    if(myproc()->killed){
801030e8:	e8 73 02 00 00       	call   80103360 <myproc>
801030ed:	8b 48 24             	mov    0x24(%eax),%ecx
801030f0:	85 c9                	test   %ecx,%ecx
801030f2:	0f 85 80 00 00 00    	jne    80103178 <piperead+0xc0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801030f8:	83 ec 08             	sub    $0x8,%esp
801030fb:	56                   	push   %esi
801030fc:	53                   	push   %ebx
801030fd:	e8 ee 07 00 00       	call   801038f0 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103102:	83 c4 10             	add    $0x10,%esp
80103105:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
8010310b:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
80103111:	75 0a                	jne    8010311d <piperead+0x65>
80103113:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
80103119:	85 c0                	test   %eax,%eax
8010311b:	75 cb                	jne    801030e8 <piperead+0x30>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010311d:	31 db                	xor    %ebx,%ebx
8010311f:	8b 55 10             	mov    0x10(%ebp),%edx
80103122:	85 d2                	test   %edx,%edx
80103124:	7f 1d                	jg     80103143 <piperead+0x8b>
80103126:	eb 29                	jmp    80103151 <piperead+0x99>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103128:	8d 48 01             	lea    0x1(%eax),%ecx
8010312b:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
80103131:	25 ff 01 00 00       	and    $0x1ff,%eax
80103136:	8a 44 06 34          	mov    0x34(%esi,%eax,1),%al
8010313a:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010313d:	43                   	inc    %ebx
8010313e:	39 5d 10             	cmp    %ebx,0x10(%ebp)
80103141:	74 0e                	je     80103151 <piperead+0x99>
    if(p->nread == p->nwrite)
80103143:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103149:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
8010314f:	75 d7                	jne    80103128 <piperead+0x70>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103151:	83 ec 0c             	sub    $0xc,%esp
80103154:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
8010315a:	50                   	push   %eax
8010315b:	e8 3c 09 00 00       	call   80103a9c <wakeup>
  release(&p->lock);
80103160:	89 34 24             	mov    %esi,(%esp)
80103163:	e8 7c 0f 00 00       	call   801040e4 <release>
  return i;
80103168:	83 c4 10             	add    $0x10,%esp
}
8010316b:	89 d8                	mov    %ebx,%eax
8010316d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103170:	5b                   	pop    %ebx
80103171:	5e                   	pop    %esi
80103172:	5f                   	pop    %edi
80103173:	5d                   	pop    %ebp
80103174:	c3                   	ret    
80103175:	8d 76 00             	lea    0x0(%esi),%esi
      release(&p->lock);
80103178:	83 ec 0c             	sub    $0xc,%esp
8010317b:	56                   	push   %esi
8010317c:	e8 63 0f 00 00       	call   801040e4 <release>
      return -1;
80103181:	83 c4 10             	add    $0x10,%esp
80103184:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80103189:	89 d8                	mov    %ebx,%eax
8010318b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010318e:	5b                   	pop    %ebx
8010318f:	5e                   	pop    %esi
80103190:	5f                   	pop    %edi
80103191:	5d                   	pop    %ebp
80103192:	c3                   	ret    
80103193:	90                   	nop

80103194 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103194:	55                   	push   %ebp
80103195:	89 e5                	mov    %esp,%ebp
80103197:	53                   	push   %ebx
80103198:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010319b:	68 00 37 11 80       	push   $0x80113700
801031a0:	e8 a7 0e 00 00       	call   8010404c <acquire>
801031a5:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031a8:	bb 34 37 11 80       	mov    $0x80113734,%ebx
801031ad:	eb 0c                	jmp    801031bb <allocproc+0x27>
801031af:	90                   	nop
801031b0:	83 eb 80             	sub    $0xffffff80,%ebx
801031b3:	81 fb 34 57 11 80    	cmp    $0x80115734,%ebx
801031b9:	74 7d                	je     80103238 <allocproc+0xa4>
    if(p->state == UNUSED)
801031bb:	8b 4b 0c             	mov    0xc(%ebx),%ecx
801031be:	85 c9                	test   %ecx,%ecx
801031c0:	75 ee                	jne    801031b0 <allocproc+0x1c>

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801031c2:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801031c9:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801031ce:	8d 50 01             	lea    0x1(%eax),%edx
801031d1:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
801031d7:	89 43 10             	mov    %eax,0x10(%ebx)
  p->tickets = 1;
801031da:	c7 43 7c 01 00 00 00 	movl   $0x1,0x7c(%ebx)
  
  release(&ptable.lock);
801031e1:	83 ec 0c             	sub    $0xc,%esp
801031e4:	68 00 37 11 80       	push   $0x80113700
801031e9:	e8 f6 0e 00 00       	call   801040e4 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801031ee:	e8 41 f0 ff ff       	call   80102234 <kalloc>
801031f3:	89 43 08             	mov    %eax,0x8(%ebx)
801031f6:	83 c4 10             	add    $0x10,%esp
801031f9:	85 c0                	test   %eax,%eax
801031fb:	74 54                	je     80103251 <allocproc+0xbd>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801031fd:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
80103203:	89 53 18             	mov    %edx,0x18(%ebx)
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
80103206:	c7 80 b0 0f 00 00 ad 	movl   $0x801050ad,0xfb0(%eax)
8010320d:	50 10 80 

  sp -= sizeof *p->context;
80103210:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103215:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103218:	52                   	push   %edx
80103219:	6a 14                	push   $0x14
8010321b:	6a 00                	push   $0x0
8010321d:	50                   	push   %eax
8010321e:	e8 09 0f 00 00       	call   8010412c <memset>
  p->context->eip = (uint)forkret;
80103223:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103226:	c7 40 10 64 32 10 80 	movl   $0x80103264,0x10(%eax)

  return p;
8010322d:	83 c4 10             	add    $0x10,%esp
}
80103230:	89 d8                	mov    %ebx,%eax
80103232:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103235:	c9                   	leave  
80103236:	c3                   	ret    
80103237:	90                   	nop
  release(&ptable.lock);
80103238:	83 ec 0c             	sub    $0xc,%esp
8010323b:	68 00 37 11 80       	push   $0x80113700
80103240:	e8 9f 0e 00 00       	call   801040e4 <release>
  return 0;
80103245:	83 c4 10             	add    $0x10,%esp
80103248:	31 db                	xor    %ebx,%ebx
}
8010324a:	89 d8                	mov    %ebx,%eax
8010324c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010324f:	c9                   	leave  
80103250:	c3                   	ret    
    p->state = UNUSED;
80103251:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103258:	31 db                	xor    %ebx,%ebx
}
8010325a:	89 d8                	mov    %ebx,%eax
8010325c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010325f:	c9                   	leave  
80103260:	c3                   	ret    
80103261:	8d 76 00             	lea    0x0(%esi),%esi

80103264 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80103264:	55                   	push   %ebp
80103265:	89 e5                	mov    %esp,%ebp
80103267:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010326a:	68 00 37 11 80       	push   $0x80113700
8010326f:	e8 70 0e 00 00       	call   801040e4 <release>

  if (first) {
80103274:	83 c4 10             	add    $0x10,%esp
80103277:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010327c:	85 c0                	test   %eax,%eax
8010327e:	75 04                	jne    80103284 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
80103280:	c9                   	leave  
80103281:	c3                   	ret    
80103282:	66 90                	xchg   %ax,%ax
    first = 0;
80103284:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
8010328b:	00 00 00 
    iinit(ROOTDEV);
8010328e:	83 ec 0c             	sub    $0xc,%esp
80103291:	6a 01                	push   $0x1
80103293:	e8 e0 e0 ff ff       	call   80101378 <iinit>
    initlog(ROOTDEV);
80103298:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010329f:	e8 08 f5 ff ff       	call   801027ac <initlog>
}
801032a4:	83 c4 10             	add    $0x10,%esp
801032a7:	c9                   	leave  
801032a8:	c3                   	ret    
801032a9:	8d 76 00             	lea    0x0(%esi),%esi

801032ac <pinit>:
{
801032ac:	55                   	push   %ebp
801032ad:	89 e5                	mov    %esp,%ebp
801032af:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801032b2:	68 e0 6c 10 80       	push   $0x80106ce0
801032b7:	68 00 37 11 80       	push   $0x80113700
801032bc:	e8 4b 0c 00 00       	call   80103f0c <initlock>
}
801032c1:	83 c4 10             	add    $0x10,%esp
801032c4:	c9                   	leave  
801032c5:	c3                   	ret    
801032c6:	66 90                	xchg   %ax,%ax

801032c8 <mycpu>:
{
801032c8:	55                   	push   %ebp
801032c9:	89 e5                	mov    %esp,%ebp
801032cb:	56                   	push   %esi
801032cc:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801032cd:	9c                   	pushf  
801032ce:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801032cf:	f6 c4 02             	test   $0x2,%ah
801032d2:	75 48                	jne    8010331c <mycpu+0x54>
  apicid = lapicid();
801032d4:	e8 83 f1 ff ff       	call   8010245c <lapicid>
  for (i = 0; i < ncpu; ++i) {
801032d9:	8b 1d e0 36 11 80    	mov    0x801136e0,%ebx
801032df:	85 db                	test   %ebx,%ebx
801032e1:	7e 2c                	jle    8010330f <mycpu+0x47>
801032e3:	31 c9                	xor    %ecx,%ecx
801032e5:	eb 06                	jmp    801032ed <mycpu+0x25>
801032e7:	90                   	nop
801032e8:	41                   	inc    %ecx
801032e9:	39 d9                	cmp    %ebx,%ecx
801032eb:	74 22                	je     8010330f <mycpu+0x47>
    if (cpus[i].apicid == apicid)
801032ed:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
801032f0:	01 d2                	add    %edx,%edx
801032f2:	01 ca                	add    %ecx,%edx
801032f4:	c1 e2 04             	shl    $0x4,%edx
801032f7:	0f b6 b2 60 31 11 80 	movzbl -0x7feecea0(%edx),%esi
801032fe:	39 c6                	cmp    %eax,%esi
80103300:	75 e6                	jne    801032e8 <mycpu+0x20>
      return &cpus[i];
80103302:	8d 82 60 31 11 80    	lea    -0x7feecea0(%edx),%eax
}
80103308:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010330b:	5b                   	pop    %ebx
8010330c:	5e                   	pop    %esi
8010330d:	5d                   	pop    %ebp
8010330e:	c3                   	ret    
  panic("unknown apicid\n");
8010330f:	83 ec 0c             	sub    $0xc,%esp
80103312:	68 e7 6c 10 80       	push   $0x80106ce7
80103317:	e8 24 d0 ff ff       	call   80100340 <panic>
    panic("mycpu called with interrupts enabled\n");
8010331c:	83 ec 0c             	sub    $0xc,%esp
8010331f:	68 c4 6d 10 80       	push   $0x80106dc4
80103324:	e8 17 d0 ff ff       	call   80100340 <panic>
80103329:	8d 76 00             	lea    0x0(%esi),%esi

8010332c <cpuid>:
cpuid() {
8010332c:	55                   	push   %ebp
8010332d:	89 e5                	mov    %esp,%ebp
8010332f:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103332:	e8 91 ff ff ff       	call   801032c8 <mycpu>
80103337:	2d 60 31 11 80       	sub    $0x80113160,%eax
8010333c:	c1 f8 04             	sar    $0x4,%eax
8010333f:	8d 0c c0             	lea    (%eax,%eax,8),%ecx
80103342:	89 ca                	mov    %ecx,%edx
80103344:	c1 e2 05             	shl    $0x5,%edx
80103347:	29 ca                	sub    %ecx,%edx
80103349:	8d 14 90             	lea    (%eax,%edx,4),%edx
8010334c:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
8010334f:	89 ca                	mov    %ecx,%edx
80103351:	c1 e2 0f             	shl    $0xf,%edx
80103354:	29 ca                	sub    %ecx,%edx
80103356:	8d 04 90             	lea    (%eax,%edx,4),%eax
80103359:	f7 d8                	neg    %eax
}
8010335b:	c9                   	leave  
8010335c:	c3                   	ret    
8010335d:	8d 76 00             	lea    0x0(%esi),%esi

80103360 <myproc>:
myproc(void) {
80103360:	55                   	push   %ebp
80103361:	89 e5                	mov    %esp,%ebp
80103363:	83 ec 18             	sub    $0x18,%esp
  pushcli();
80103366:	e8 05 0c 00 00       	call   80103f70 <pushcli>
  c = mycpu();
8010336b:	e8 58 ff ff ff       	call   801032c8 <mycpu>
  p = c->proc;
80103370:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103376:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
80103379:	e8 3a 0c 00 00       	call   80103fb8 <popcli>
}
8010337e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103381:	c9                   	leave  
80103382:	c3                   	ret    
80103383:	90                   	nop

80103384 <userinit>:
{
80103384:	55                   	push   %ebp
80103385:	89 e5                	mov    %esp,%ebp
80103387:	53                   	push   %ebx
80103388:	51                   	push   %ecx
  p = allocproc();
80103389:	e8 06 fe ff ff       	call   80103194 <allocproc>
8010338e:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103390:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
80103395:	e8 aa 31 00 00       	call   80106544 <setupkvm>
8010339a:	89 43 04             	mov    %eax,0x4(%ebx)
8010339d:	85 c0                	test   %eax,%eax
8010339f:	0f 84 b3 00 00 00    	je     80103458 <userinit+0xd4>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801033a5:	52                   	push   %edx
801033a6:	68 2c 00 00 00       	push   $0x2c
801033ab:	68 60 a4 10 80       	push   $0x8010a460
801033b0:	50                   	push   %eax
801033b1:	e8 aa 2e 00 00       	call   80106260 <inituvm>
  p->sz = PGSIZE;
801033b6:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801033bc:	83 c4 0c             	add    $0xc,%esp
801033bf:	6a 4c                	push   $0x4c
801033c1:	6a 00                	push   $0x0
801033c3:	ff 73 18             	pushl  0x18(%ebx)
801033c6:	e8 61 0d 00 00       	call   8010412c <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801033cb:	8b 43 18             	mov    0x18(%ebx),%eax
801033ce:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801033d4:	8b 43 18             	mov    0x18(%ebx),%eax
801033d7:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801033dd:	8b 43 18             	mov    0x18(%ebx),%eax
801033e0:	8b 50 2c             	mov    0x2c(%eax),%edx
801033e3:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801033e7:	8b 43 18             	mov    0x18(%ebx),%eax
801033ea:	8b 50 2c             	mov    0x2c(%eax),%edx
801033ed:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801033f1:	8b 43 18             	mov    0x18(%ebx),%eax
801033f4:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801033fb:	8b 43 18             	mov    0x18(%ebx),%eax
801033fe:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103405:	8b 43 18             	mov    0x18(%ebx),%eax
80103408:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
8010340f:	83 c4 0c             	add    $0xc,%esp
80103412:	6a 10                	push   $0x10
80103414:	68 10 6d 10 80       	push   $0x80106d10
80103419:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010341c:	50                   	push   %eax
8010341d:	e8 5e 0e 00 00       	call   80104280 <safestrcpy>
  p->cwd = namei("/");
80103422:	c7 04 24 19 6d 10 80 	movl   $0x80106d19,(%esp)
80103429:	e8 e2 e8 ff ff       	call   80101d10 <namei>
8010342e:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103431:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103438:	e8 0f 0c 00 00       	call   8010404c <acquire>
  p->state = RUNNABLE;
8010343d:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103444:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010344b:	e8 94 0c 00 00       	call   801040e4 <release>
}
80103450:	83 c4 10             	add    $0x10,%esp
80103453:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103456:	c9                   	leave  
80103457:	c3                   	ret    
    panic("userinit: out of memory?");
80103458:	83 ec 0c             	sub    $0xc,%esp
8010345b:	68 f7 6c 10 80       	push   $0x80106cf7
80103460:	e8 db ce ff ff       	call   80100340 <panic>
80103465:	8d 76 00             	lea    0x0(%esi),%esi

80103468 <growproc>:
{
80103468:	55                   	push   %ebp
80103469:	89 e5                	mov    %esp,%ebp
8010346b:	56                   	push   %esi
8010346c:	53                   	push   %ebx
8010346d:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103470:	e8 fb 0a 00 00       	call   80103f70 <pushcli>
  c = mycpu();
80103475:	e8 4e fe ff ff       	call   801032c8 <mycpu>
  p = c->proc;
8010347a:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103480:	e8 33 0b 00 00       	call   80103fb8 <popcli>
  sz = curproc->sz;
80103485:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103487:	85 f6                	test   %esi,%esi
80103489:	7f 19                	jg     801034a4 <growproc+0x3c>
  } else if(n < 0){
8010348b:	75 33                	jne    801034c0 <growproc+0x58>
  curproc->sz = sz;
8010348d:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
8010348f:	83 ec 0c             	sub    $0xc,%esp
80103492:	53                   	push   %ebx
80103493:	e8 cc 2c 00 00       	call   80106164 <switchuvm>
  return 0;
80103498:	83 c4 10             	add    $0x10,%esp
8010349b:	31 c0                	xor    %eax,%eax
}
8010349d:	8d 65 f8             	lea    -0x8(%ebp),%esp
801034a0:	5b                   	pop    %ebx
801034a1:	5e                   	pop    %esi
801034a2:	5d                   	pop    %ebp
801034a3:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801034a4:	51                   	push   %ecx
801034a5:	01 c6                	add    %eax,%esi
801034a7:	56                   	push   %esi
801034a8:	50                   	push   %eax
801034a9:	ff 73 04             	pushl  0x4(%ebx)
801034ac:	e8 df 2e 00 00       	call   80106390 <allocuvm>
801034b1:	83 c4 10             	add    $0x10,%esp
801034b4:	85 c0                	test   %eax,%eax
801034b6:	75 d5                	jne    8010348d <growproc+0x25>
      return -1;
801034b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034bd:	eb de                	jmp    8010349d <growproc+0x35>
801034bf:	90                   	nop
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801034c0:	52                   	push   %edx
801034c1:	01 c6                	add    %eax,%esi
801034c3:	56                   	push   %esi
801034c4:	50                   	push   %eax
801034c5:	ff 73 04             	pushl  0x4(%ebx)
801034c8:	e8 eb 2f 00 00       	call   801064b8 <deallocuvm>
801034cd:	83 c4 10             	add    $0x10,%esp
801034d0:	85 c0                	test   %eax,%eax
801034d2:	75 b9                	jne    8010348d <growproc+0x25>
801034d4:	eb e2                	jmp    801034b8 <growproc+0x50>
801034d6:	66 90                	xchg   %ax,%ax

801034d8 <fork>:
{
801034d8:	55                   	push   %ebp
801034d9:	89 e5                	mov    %esp,%ebp
801034db:	57                   	push   %edi
801034dc:	56                   	push   %esi
801034dd:	53                   	push   %ebx
801034de:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
801034e1:	e8 8a 0a 00 00       	call   80103f70 <pushcli>
  c = mycpu();
801034e6:	e8 dd fd ff ff       	call   801032c8 <mycpu>
  p = c->proc;
801034eb:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801034f1:	e8 c2 0a 00 00       	call   80103fb8 <popcli>
  if((np = allocproc()) == 0){
801034f6:	e8 99 fc ff ff       	call   80103194 <allocproc>
801034fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801034fe:	85 c0                	test   %eax,%eax
80103500:	0f 84 c1 00 00 00    	je     801035c7 <fork+0xef>
80103506:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103508:	83 ec 08             	sub    $0x8,%esp
8010350b:	ff 33                	pushl  (%ebx)
8010350d:	ff 73 04             	pushl  0x4(%ebx)
80103510:	e8 eb 30 00 00       	call   80106600 <copyuvm>
80103515:	89 47 04             	mov    %eax,0x4(%edi)
80103518:	83 c4 10             	add    $0x10,%esp
8010351b:	85 c0                	test   %eax,%eax
8010351d:	0f 84 ab 00 00 00    	je     801035ce <fork+0xf6>
  np->sz = curproc->sz;
80103523:	8b 03                	mov    (%ebx),%eax
80103525:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103528:	89 01                	mov    %eax,(%ecx)
  np->tickets = curproc->tickets;
8010352a:	8b 43 7c             	mov    0x7c(%ebx),%eax
8010352d:	89 41 7c             	mov    %eax,0x7c(%ecx)
  np->parent = curproc;
80103530:	89 c8                	mov    %ecx,%eax
80103532:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103535:	8b 73 18             	mov    0x18(%ebx),%esi
80103538:	8b 79 18             	mov    0x18(%ecx),%edi
8010353b:	b9 13 00 00 00       	mov    $0x13,%ecx
80103540:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103542:	8b 40 18             	mov    0x18(%eax),%eax
80103545:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010354c:	31 f6                	xor    %esi,%esi
8010354e:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[i])
80103550:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103554:	85 c0                	test   %eax,%eax
80103556:	74 13                	je     8010356b <fork+0x93>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103558:	83 ec 0c             	sub    $0xc,%esp
8010355b:	50                   	push   %eax
8010355c:	e8 f7 d7 ff ff       	call   80100d58 <filedup>
80103561:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103564:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103568:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NOFILE; i++)
8010356b:	46                   	inc    %esi
8010356c:	83 fe 10             	cmp    $0x10,%esi
8010356f:	75 df                	jne    80103550 <fork+0x78>
  np->cwd = idup(curproc->cwd);
80103571:	83 ec 0c             	sub    $0xc,%esp
80103574:	ff 73 68             	pushl  0x68(%ebx)
80103577:	e8 b4 df ff ff       	call   80101530 <idup>
8010357c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010357f:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103582:	83 c4 0c             	add    $0xc,%esp
80103585:	6a 10                	push   $0x10
80103587:	83 c3 6c             	add    $0x6c,%ebx
8010358a:	53                   	push   %ebx
8010358b:	8d 47 6c             	lea    0x6c(%edi),%eax
8010358e:	50                   	push   %eax
8010358f:	e8 ec 0c 00 00       	call   80104280 <safestrcpy>
  pid = np->pid;
80103594:	8b 47 10             	mov    0x10(%edi),%eax
80103597:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  acquire(&ptable.lock);
8010359a:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801035a1:	e8 a6 0a 00 00       	call   8010404c <acquire>
  np->state = RUNNABLE;
801035a6:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
801035ad:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801035b4:	e8 2b 0b 00 00       	call   801040e4 <release>
  return pid;
801035b9:	83 c4 10             	add    $0x10,%esp
801035bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
801035bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801035c2:	5b                   	pop    %ebx
801035c3:	5e                   	pop    %esi
801035c4:	5f                   	pop    %edi
801035c5:	5d                   	pop    %ebp
801035c6:	c3                   	ret    
    return -1;
801035c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801035cc:	eb f1                	jmp    801035bf <fork+0xe7>
    kfree(np->kstack);
801035ce:	83 ec 0c             	sub    $0xc,%esp
801035d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801035d4:	ff 73 08             	pushl  0x8(%ebx)
801035d7:	e8 c8 ea ff ff       	call   801020a4 <kfree>
    np->kstack = 0;
801035dc:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
801035e3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
801035ea:	83 c4 10             	add    $0x10,%esp
801035ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801035f2:	eb cb                	jmp    801035bf <fork+0xe7>

801035f4 <get_total_tickets>:
  int total_tickets = 0;
801035f4:	31 d2                	xor    %edx,%edx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035f6:	b8 34 37 11 80       	mov    $0x80113734,%eax
801035fb:	90                   	nop
    if (p->state == RUNNABLE) {
801035fc:	83 78 0c 03          	cmpl   $0x3,0xc(%eax)
80103600:	75 03                	jne    80103605 <get_total_tickets+0x11>
      total_tickets += p->tickets;
80103602:	03 50 7c             	add    0x7c(%eax),%edx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103605:	83 e8 80             	sub    $0xffffff80,%eax
80103608:	3d 34 57 11 80       	cmp    $0x80115734,%eax
8010360d:	75 ed                	jne    801035fc <get_total_tickets+0x8>
}
8010360f:	89 d0                	mov    %edx,%eax
80103611:	c3                   	ret    
80103612:	66 90                	xchg   %ax,%ax

80103614 <scheduler>:
{
80103614:	55                   	push   %ebp
80103615:	89 e5                	mov    %esp,%ebp
80103617:	57                   	push   %edi
80103618:	56                   	push   %esi
80103619:	53                   	push   %ebx
8010361a:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
8010361d:	e8 a6 fc ff ff       	call   801032c8 <mycpu>
80103622:	89 c3                	mov    %eax,%ebx
  c->proc = 0;
80103624:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010362b:	00 00 00 
  int current_ticket_total = 0;
8010362e:	8d 70 04             	lea    0x4(%eax),%esi
80103631:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103634:	fb                   	sti    
    acquire(&ptable.lock);
80103635:	83 ec 0c             	sub    $0xc,%esp
80103638:	68 00 37 11 80       	push   $0x80113700
8010363d:	e8 0a 0a 00 00       	call   8010404c <acquire>
80103642:	83 c4 10             	add    $0x10,%esp
  int total_tickets = 0;
80103645:	31 d2                	xor    %edx,%edx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103647:	b8 34 37 11 80       	mov    $0x80113734,%eax
    if (p->state == RUNNABLE) {
8010364c:	83 78 0c 03          	cmpl   $0x3,0xc(%eax)
80103650:	75 03                	jne    80103655 <scheduler+0x41>
      total_tickets += p->tickets;
80103652:	03 50 7c             	add    0x7c(%eax),%edx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103655:	83 e8 80             	sub    $0xffffff80,%eax
80103658:	3d 34 57 11 80       	cmp    $0x80115734,%eax
8010365d:	75 ed                	jne    8010364c <scheduler+0x38>
    winner_ticket = random_at_most(total_tickets);
8010365f:	83 ec 0c             	sub    $0xc,%esp
80103662:	52                   	push   %edx
80103663:	e8 64 07 00 00       	call   80103dcc <random_at_most>
80103668:	83 c4 10             	add    $0x10,%esp
    current_ticket_total = 0;
8010366b:	31 d2                	xor    %edx,%edx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010366d:	bf 34 37 11 80       	mov    $0x80113734,%edi
      if(p->state != RUNNABLE)
80103672:	83 7f 0c 03          	cmpl   $0x3,0xc(%edi)
80103676:	75 50                	jne    801036c8 <scheduler+0xb4>
      current_ticket_total += p->tickets;
80103678:	03 57 7c             	add    0x7c(%edi),%edx
      if (current_ticket_total < winner_ticket) {
8010367b:	39 d0                	cmp    %edx,%eax
8010367d:	7f 49                	jg     801036c8 <scheduler+0xb4>
      c->proc = p;
8010367f:	89 bb ac 00 00 00    	mov    %edi,0xac(%ebx)
      switchuvm(p);
80103685:	83 ec 0c             	sub    $0xc,%esp
80103688:	57                   	push   %edi
80103689:	e8 d6 2a 00 00       	call   80106164 <switchuvm>
      p->state = RUNNING;
8010368e:	c7 47 0c 04 00 00 00 	movl   $0x4,0xc(%edi)
      swtch(&(c->scheduler), p->context);
80103695:	58                   	pop    %eax
80103696:	5a                   	pop    %edx
80103697:	ff 77 1c             	pushl  0x1c(%edi)
8010369a:	56                   	push   %esi
8010369b:	e8 2d 0c 00 00       	call   801042cd <swtch>
      switchkvm();
801036a0:	e8 af 2a 00 00       	call   80106154 <switchkvm>
      c->proc = 0;
801036a5:	c7 83 ac 00 00 00 00 	movl   $0x0,0xac(%ebx)
801036ac:	00 00 00 
      break;
801036af:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
801036b2:	83 ec 0c             	sub    $0xc,%esp
801036b5:	68 00 37 11 80       	push   $0x80113700
801036ba:	e8 25 0a 00 00       	call   801040e4 <release>
    sti();
801036bf:	83 c4 10             	add    $0x10,%esp
801036c2:	e9 6d ff ff ff       	jmp    80103634 <scheduler+0x20>
801036c7:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036c8:	83 ef 80             	sub    $0xffffff80,%edi
801036cb:	81 ff 34 57 11 80    	cmp    $0x80115734,%edi
801036d1:	75 9f                	jne    80103672 <scheduler+0x5e>
801036d3:	eb dd                	jmp    801036b2 <scheduler+0x9e>
801036d5:	8d 76 00             	lea    0x0(%esi),%esi

801036d8 <sched>:
{
801036d8:	55                   	push   %ebp
801036d9:	89 e5                	mov    %esp,%ebp
801036db:	56                   	push   %esi
801036dc:	53                   	push   %ebx
  pushcli();
801036dd:	e8 8e 08 00 00       	call   80103f70 <pushcli>
  c = mycpu();
801036e2:	e8 e1 fb ff ff       	call   801032c8 <mycpu>
  p = c->proc;
801036e7:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801036ed:	e8 c6 08 00 00       	call   80103fb8 <popcli>
  if(!holding(&ptable.lock))
801036f2:	83 ec 0c             	sub    $0xc,%esp
801036f5:	68 00 37 11 80       	push   $0x80113700
801036fa:	e8 11 09 00 00       	call   80104010 <holding>
801036ff:	83 c4 10             	add    $0x10,%esp
80103702:	85 c0                	test   %eax,%eax
80103704:	74 4f                	je     80103755 <sched+0x7d>
  if(mycpu()->ncli != 1)
80103706:	e8 bd fb ff ff       	call   801032c8 <mycpu>
8010370b:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103712:	75 68                	jne    8010377c <sched+0xa4>
  if(p->state == RUNNING)
80103714:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103718:	74 55                	je     8010376f <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010371a:	9c                   	pushf  
8010371b:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010371c:	f6 c4 02             	test   $0x2,%ah
8010371f:	75 41                	jne    80103762 <sched+0x8a>
  intena = mycpu()->intena;
80103721:	e8 a2 fb ff ff       	call   801032c8 <mycpu>
80103726:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
8010372c:	e8 97 fb ff ff       	call   801032c8 <mycpu>
80103731:	83 ec 08             	sub    $0x8,%esp
80103734:	ff 70 04             	pushl  0x4(%eax)
80103737:	83 c3 1c             	add    $0x1c,%ebx
8010373a:	53                   	push   %ebx
8010373b:	e8 8d 0b 00 00       	call   801042cd <swtch>
  mycpu()->intena = intena;
80103740:	e8 83 fb ff ff       	call   801032c8 <mycpu>
80103745:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010374b:	83 c4 10             	add    $0x10,%esp
8010374e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103751:	5b                   	pop    %ebx
80103752:	5e                   	pop    %esi
80103753:	5d                   	pop    %ebp
80103754:	c3                   	ret    
    panic("sched ptable.lock");
80103755:	83 ec 0c             	sub    $0xc,%esp
80103758:	68 1b 6d 10 80       	push   $0x80106d1b
8010375d:	e8 de cb ff ff       	call   80100340 <panic>
    panic("sched interruptible");
80103762:	83 ec 0c             	sub    $0xc,%esp
80103765:	68 47 6d 10 80       	push   $0x80106d47
8010376a:	e8 d1 cb ff ff       	call   80100340 <panic>
    panic("sched running");
8010376f:	83 ec 0c             	sub    $0xc,%esp
80103772:	68 39 6d 10 80       	push   $0x80106d39
80103777:	e8 c4 cb ff ff       	call   80100340 <panic>
    panic("sched locks");
8010377c:	83 ec 0c             	sub    $0xc,%esp
8010377f:	68 2d 6d 10 80       	push   $0x80106d2d
80103784:	e8 b7 cb ff ff       	call   80100340 <panic>
80103789:	8d 76 00             	lea    0x0(%esi),%esi

8010378c <exit>:
{
8010378c:	55                   	push   %ebp
8010378d:	89 e5                	mov    %esp,%ebp
8010378f:	57                   	push   %edi
80103790:	56                   	push   %esi
80103791:	53                   	push   %ebx
80103792:	83 ec 0c             	sub    $0xc,%esp
  pushcli();
80103795:	e8 d6 07 00 00       	call   80103f70 <pushcli>
  c = mycpu();
8010379a:	e8 29 fb ff ff       	call   801032c8 <mycpu>
  p = c->proc;
8010379f:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
801037a5:	e8 0e 08 00 00       	call   80103fb8 <popcli>
  if(curproc == initproc)
801037aa:	39 35 b8 a5 10 80    	cmp    %esi,0x8010a5b8
801037b0:	0f 84 e5 00 00 00    	je     8010389b <exit+0x10f>
801037b6:	8d 5e 28             	lea    0x28(%esi),%ebx
801037b9:	8d 7e 68             	lea    0x68(%esi),%edi
    if(curproc->ofile[fd]){
801037bc:	8b 03                	mov    (%ebx),%eax
801037be:	85 c0                	test   %eax,%eax
801037c0:	74 12                	je     801037d4 <exit+0x48>
      fileclose(curproc->ofile[fd]);
801037c2:	83 ec 0c             	sub    $0xc,%esp
801037c5:	50                   	push   %eax
801037c6:	e8 d1 d5 ff ff       	call   80100d9c <fileclose>
      curproc->ofile[fd] = 0;
801037cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
801037d1:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
801037d4:	83 c3 04             	add    $0x4,%ebx
801037d7:	39 df                	cmp    %ebx,%edi
801037d9:	75 e1                	jne    801037bc <exit+0x30>
  begin_op();
801037db:	e8 5c f0 ff ff       	call   8010283c <begin_op>
  iput(curproc->cwd);
801037e0:	83 ec 0c             	sub    $0xc,%esp
801037e3:	ff 76 68             	pushl  0x68(%esi)
801037e6:	e8 7d de ff ff       	call   80101668 <iput>
  end_op();
801037eb:	e8 b4 f0 ff ff       	call   801028a4 <end_op>
  curproc->cwd = 0;
801037f0:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801037f7:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801037fe:	e8 49 08 00 00       	call   8010404c <acquire>
  wakeup1(curproc->parent);
80103803:	8b 56 14             	mov    0x14(%esi),%edx
80103806:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103809:	b8 34 37 11 80       	mov    $0x80113734,%eax
8010380e:	eb 0a                	jmp    8010381a <exit+0x8e>
80103810:	83 e8 80             	sub    $0xffffff80,%eax
80103813:	3d 34 57 11 80       	cmp    $0x80115734,%eax
80103818:	74 1c                	je     80103836 <exit+0xaa>
    if(p->state == SLEEPING && p->chan == chan)
8010381a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010381e:	75 f0                	jne    80103810 <exit+0x84>
80103820:	3b 50 20             	cmp    0x20(%eax),%edx
80103823:	75 eb                	jne    80103810 <exit+0x84>
      p->state = RUNNABLE;
80103825:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010382c:	83 e8 80             	sub    $0xffffff80,%eax
8010382f:	3d 34 57 11 80       	cmp    $0x80115734,%eax
80103834:	75 e4                	jne    8010381a <exit+0x8e>
      p->parent = initproc;
80103836:	8b 0d b8 a5 10 80    	mov    0x8010a5b8,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010383c:	ba 34 37 11 80       	mov    $0x80113734,%edx
80103841:	eb 0c                	jmp    8010384f <exit+0xc3>
80103843:	90                   	nop
80103844:	83 ea 80             	sub    $0xffffff80,%edx
80103847:	81 fa 34 57 11 80    	cmp    $0x80115734,%edx
8010384d:	74 33                	je     80103882 <exit+0xf6>
    if(p->parent == curproc){
8010384f:	39 72 14             	cmp    %esi,0x14(%edx)
80103852:	75 f0                	jne    80103844 <exit+0xb8>
      p->parent = initproc;
80103854:	89 4a 14             	mov    %ecx,0x14(%edx)
      if(p->state == ZOMBIE)
80103857:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
8010385b:	75 e7                	jne    80103844 <exit+0xb8>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010385d:	b8 34 37 11 80       	mov    $0x80113734,%eax
80103862:	eb 0a                	jmp    8010386e <exit+0xe2>
80103864:	83 e8 80             	sub    $0xffffff80,%eax
80103867:	3d 34 57 11 80       	cmp    $0x80115734,%eax
8010386c:	74 d6                	je     80103844 <exit+0xb8>
    if(p->state == SLEEPING && p->chan == chan)
8010386e:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103872:	75 f0                	jne    80103864 <exit+0xd8>
80103874:	3b 48 20             	cmp    0x20(%eax),%ecx
80103877:	75 eb                	jne    80103864 <exit+0xd8>
      p->state = RUNNABLE;
80103879:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103880:	eb e2                	jmp    80103864 <exit+0xd8>
  curproc->state = ZOMBIE;
80103882:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103889:	e8 4a fe ff ff       	call   801036d8 <sched>
  panic("zombie exit");
8010388e:	83 ec 0c             	sub    $0xc,%esp
80103891:	68 68 6d 10 80       	push   $0x80106d68
80103896:	e8 a5 ca ff ff       	call   80100340 <panic>
    panic("init exiting");
8010389b:	83 ec 0c             	sub    $0xc,%esp
8010389e:	68 5b 6d 10 80       	push   $0x80106d5b
801038a3:	e8 98 ca ff ff       	call   80100340 <panic>

801038a8 <yield>:
{
801038a8:	55                   	push   %ebp
801038a9:	89 e5                	mov    %esp,%ebp
801038ab:	53                   	push   %ebx
801038ac:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801038af:	68 00 37 11 80       	push   $0x80113700
801038b4:	e8 93 07 00 00       	call   8010404c <acquire>
  pushcli();
801038b9:	e8 b2 06 00 00       	call   80103f70 <pushcli>
  c = mycpu();
801038be:	e8 05 fa ff ff       	call   801032c8 <mycpu>
  p = c->proc;
801038c3:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801038c9:	e8 ea 06 00 00       	call   80103fb8 <popcli>
  myproc()->state = RUNNABLE;
801038ce:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  sched();
801038d5:	e8 fe fd ff ff       	call   801036d8 <sched>
  release(&ptable.lock);
801038da:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
801038e1:	e8 fe 07 00 00       	call   801040e4 <release>
}
801038e6:	83 c4 10             	add    $0x10,%esp
801038e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038ec:	c9                   	leave  
801038ed:	c3                   	ret    
801038ee:	66 90                	xchg   %ax,%ax

801038f0 <sleep>:
{
801038f0:	55                   	push   %ebp
801038f1:	89 e5                	mov    %esp,%ebp
801038f3:	57                   	push   %edi
801038f4:	56                   	push   %esi
801038f5:	53                   	push   %ebx
801038f6:	83 ec 0c             	sub    $0xc,%esp
801038f9:	8b 7d 08             	mov    0x8(%ebp),%edi
801038fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
801038ff:	e8 6c 06 00 00       	call   80103f70 <pushcli>
  c = mycpu();
80103904:	e8 bf f9 ff ff       	call   801032c8 <mycpu>
  p = c->proc;
80103909:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010390f:	e8 a4 06 00 00       	call   80103fb8 <popcli>
  if(p == 0)
80103914:	85 db                	test   %ebx,%ebx
80103916:	0f 84 83 00 00 00    	je     8010399f <sleep+0xaf>
  if(lk == 0)
8010391c:	85 f6                	test   %esi,%esi
8010391e:	74 72                	je     80103992 <sleep+0xa2>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103920:	81 fe 00 37 11 80    	cmp    $0x80113700,%esi
80103926:	74 4c                	je     80103974 <sleep+0x84>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103928:	83 ec 0c             	sub    $0xc,%esp
8010392b:	68 00 37 11 80       	push   $0x80113700
80103930:	e8 17 07 00 00       	call   8010404c <acquire>
    release(lk);
80103935:	89 34 24             	mov    %esi,(%esp)
80103938:	e8 a7 07 00 00       	call   801040e4 <release>
  p->chan = chan;
8010393d:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
80103940:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80103947:	e8 8c fd ff ff       	call   801036d8 <sched>
  p->chan = 0;
8010394c:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
    release(&ptable.lock);
80103953:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
8010395a:	e8 85 07 00 00       	call   801040e4 <release>
    acquire(lk);
8010395f:	83 c4 10             	add    $0x10,%esp
80103962:	89 75 08             	mov    %esi,0x8(%ebp)
}
80103965:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103968:	5b                   	pop    %ebx
80103969:	5e                   	pop    %esi
8010396a:	5f                   	pop    %edi
8010396b:	5d                   	pop    %ebp
    acquire(lk);
8010396c:	e9 db 06 00 00       	jmp    8010404c <acquire>
80103971:	8d 76 00             	lea    0x0(%esi),%esi
  p->chan = chan;
80103974:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
80103977:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
8010397e:	e8 55 fd ff ff       	call   801036d8 <sched>
  p->chan = 0;
80103983:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
8010398a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010398d:	5b                   	pop    %ebx
8010398e:	5e                   	pop    %esi
8010398f:	5f                   	pop    %edi
80103990:	5d                   	pop    %ebp
80103991:	c3                   	ret    
    panic("sleep without lk");
80103992:	83 ec 0c             	sub    $0xc,%esp
80103995:	68 7a 6d 10 80       	push   $0x80106d7a
8010399a:	e8 a1 c9 ff ff       	call   80100340 <panic>
    panic("sleep");
8010399f:	83 ec 0c             	sub    $0xc,%esp
801039a2:	68 74 6d 10 80       	push   $0x80106d74
801039a7:	e8 94 c9 ff ff       	call   80100340 <panic>

801039ac <wait>:
{
801039ac:	55                   	push   %ebp
801039ad:	89 e5                	mov    %esp,%ebp
801039af:	56                   	push   %esi
801039b0:	53                   	push   %ebx
801039b1:	83 ec 10             	sub    $0x10,%esp
  pushcli();
801039b4:	e8 b7 05 00 00       	call   80103f70 <pushcli>
  c = mycpu();
801039b9:	e8 0a f9 ff ff       	call   801032c8 <mycpu>
  p = c->proc;
801039be:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
801039c4:	e8 ef 05 00 00       	call   80103fb8 <popcli>
  acquire(&ptable.lock);
801039c9:	83 ec 0c             	sub    $0xc,%esp
801039cc:	68 00 37 11 80       	push   $0x80113700
801039d1:	e8 76 06 00 00       	call   8010404c <acquire>
801039d6:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801039d9:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039db:	bb 34 37 11 80       	mov    $0x80113734,%ebx
801039e0:	eb 0d                	jmp    801039ef <wait+0x43>
801039e2:	66 90                	xchg   %ax,%ax
801039e4:	83 eb 80             	sub    $0xffffff80,%ebx
801039e7:	81 fb 34 57 11 80    	cmp    $0x80115734,%ebx
801039ed:	74 1b                	je     80103a0a <wait+0x5e>
      if(p->parent != curproc)
801039ef:	39 73 14             	cmp    %esi,0x14(%ebx)
801039f2:	75 f0                	jne    801039e4 <wait+0x38>
      if(p->state == ZOMBIE){
801039f4:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801039f8:	74 2e                	je     80103a28 <wait+0x7c>
      havekids = 1;
801039fa:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039ff:	83 eb 80             	sub    $0xffffff80,%ebx
80103a02:	81 fb 34 57 11 80    	cmp    $0x80115734,%ebx
80103a08:	75 e5                	jne    801039ef <wait+0x43>
    if(!havekids || curproc->killed){
80103a0a:	85 c0                	test   %eax,%eax
80103a0c:	74 74                	je     80103a82 <wait+0xd6>
80103a0e:	8b 46 24             	mov    0x24(%esi),%eax
80103a11:	85 c0                	test   %eax,%eax
80103a13:	75 6d                	jne    80103a82 <wait+0xd6>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103a15:	83 ec 08             	sub    $0x8,%esp
80103a18:	68 00 37 11 80       	push   $0x80113700
80103a1d:	56                   	push   %esi
80103a1e:	e8 cd fe ff ff       	call   801038f0 <sleep>
    havekids = 0;
80103a23:	83 c4 10             	add    $0x10,%esp
80103a26:	eb b1                	jmp    801039d9 <wait+0x2d>
        pid = p->pid;
80103a28:	8b 43 10             	mov    0x10(%ebx),%eax
80103a2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        kfree(p->kstack);
80103a2e:	83 ec 0c             	sub    $0xc,%esp
80103a31:	ff 73 08             	pushl  0x8(%ebx)
80103a34:	e8 6b e6 ff ff       	call   801020a4 <kfree>
        p->kstack = 0;
80103a39:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103a40:	5a                   	pop    %edx
80103a41:	ff 73 04             	pushl  0x4(%ebx)
80103a44:	e8 8b 2a 00 00       	call   801064d4 <freevm>
        p->pid = 0;
80103a49:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103a50:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103a57:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103a5b:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103a62:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103a69:	c7 04 24 00 37 11 80 	movl   $0x80113700,(%esp)
80103a70:	e8 6f 06 00 00       	call   801040e4 <release>
        return pid;
80103a75:	83 c4 10             	add    $0x10,%esp
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103a7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a7e:	5b                   	pop    %ebx
80103a7f:	5e                   	pop    %esi
80103a80:	5d                   	pop    %ebp
80103a81:	c3                   	ret    
      release(&ptable.lock);
80103a82:	83 ec 0c             	sub    $0xc,%esp
80103a85:	68 00 37 11 80       	push   $0x80113700
80103a8a:	e8 55 06 00 00       	call   801040e4 <release>
      return -1;
80103a8f:	83 c4 10             	add    $0x10,%esp
80103a92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a97:	eb e2                	jmp    80103a7b <wait+0xcf>
80103a99:	8d 76 00             	lea    0x0(%esi),%esi

80103a9c <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103a9c:	55                   	push   %ebp
80103a9d:	89 e5                	mov    %esp,%ebp
80103a9f:	53                   	push   %ebx
80103aa0:	83 ec 10             	sub    $0x10,%esp
80103aa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
80103aa6:	68 00 37 11 80       	push   $0x80113700
80103aab:	e8 9c 05 00 00       	call   8010404c <acquire>
80103ab0:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ab3:	b8 34 37 11 80       	mov    $0x80113734,%eax
80103ab8:	eb 0c                	jmp    80103ac6 <wakeup+0x2a>
80103aba:	66 90                	xchg   %ax,%ax
80103abc:	83 e8 80             	sub    $0xffffff80,%eax
80103abf:	3d 34 57 11 80       	cmp    $0x80115734,%eax
80103ac4:	74 1c                	je     80103ae2 <wakeup+0x46>
    if(p->state == SLEEPING && p->chan == chan)
80103ac6:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103aca:	75 f0                	jne    80103abc <wakeup+0x20>
80103acc:	3b 58 20             	cmp    0x20(%eax),%ebx
80103acf:	75 eb                	jne    80103abc <wakeup+0x20>
      p->state = RUNNABLE;
80103ad1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ad8:	83 e8 80             	sub    $0xffffff80,%eax
80103adb:	3d 34 57 11 80       	cmp    $0x80115734,%eax
80103ae0:	75 e4                	jne    80103ac6 <wakeup+0x2a>
  wakeup1(chan);
  release(&ptable.lock);
80103ae2:	c7 45 08 00 37 11 80 	movl   $0x80113700,0x8(%ebp)
}
80103ae9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103aec:	c9                   	leave  
  release(&ptable.lock);
80103aed:	e9 f2 05 00 00       	jmp    801040e4 <release>
80103af2:	66 90                	xchg   %ax,%ax

80103af4 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103af4:	55                   	push   %ebp
80103af5:	89 e5                	mov    %esp,%ebp
80103af7:	53                   	push   %ebx
80103af8:	83 ec 10             	sub    $0x10,%esp
80103afb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103afe:	68 00 37 11 80       	push   $0x80113700
80103b03:	e8 44 05 00 00       	call   8010404c <acquire>
80103b08:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b0b:	b8 34 37 11 80       	mov    $0x80113734,%eax
80103b10:	eb 0c                	jmp    80103b1e <kill+0x2a>
80103b12:	66 90                	xchg   %ax,%ax
80103b14:	83 e8 80             	sub    $0xffffff80,%eax
80103b17:	3d 34 57 11 80       	cmp    $0x80115734,%eax
80103b1c:	74 32                	je     80103b50 <kill+0x5c>
    if(p->pid == pid){
80103b1e:	39 58 10             	cmp    %ebx,0x10(%eax)
80103b21:	75 f1                	jne    80103b14 <kill+0x20>
      p->killed = 1;
80103b23:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103b2a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103b2e:	75 07                	jne    80103b37 <kill+0x43>
        p->state = RUNNABLE;
80103b30:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80103b37:	83 ec 0c             	sub    $0xc,%esp
80103b3a:	68 00 37 11 80       	push   $0x80113700
80103b3f:	e8 a0 05 00 00       	call   801040e4 <release>
      return 0;
80103b44:	83 c4 10             	add    $0x10,%esp
80103b47:	31 c0                	xor    %eax,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103b49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b4c:	c9                   	leave  
80103b4d:	c3                   	ret    
80103b4e:	66 90                	xchg   %ax,%ax
  release(&ptable.lock);
80103b50:	83 ec 0c             	sub    $0xc,%esp
80103b53:	68 00 37 11 80       	push   $0x80113700
80103b58:	e8 87 05 00 00       	call   801040e4 <release>
  return -1;
80103b5d:	83 c4 10             	add    $0x10,%esp
80103b60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103b65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b68:	c9                   	leave  
80103b69:	c3                   	ret    
80103b6a:	66 90                	xchg   %ax,%ax

80103b6c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103b6c:	55                   	push   %ebp
80103b6d:	89 e5                	mov    %esp,%ebp
80103b6f:	57                   	push   %edi
80103b70:	56                   	push   %esi
80103b71:	53                   	push   %ebx
80103b72:	83 ec 3c             	sub    $0x3c,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b75:	bb a0 37 11 80       	mov    $0x801137a0,%ebx
80103b7a:	8d 75 e8             	lea    -0x18(%ebp),%esi
80103b7d:	eb 45                	jmp    80103bc4 <procdump+0x58>
80103b7f:	90                   	nop
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103b80:	8b 04 85 ec 6d 10 80 	mov    -0x7fef9214(,%eax,4),%eax
80103b87:	85 c0                	test   %eax,%eax
80103b89:	74 45                	je     80103bd0 <procdump+0x64>
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name, p->tickets);
80103b8b:	83 ec 0c             	sub    $0xc,%esp
80103b8e:	ff 73 10             	pushl  0x10(%ebx)
80103b91:	53                   	push   %ebx
80103b92:	50                   	push   %eax
80103b93:	ff 73 a4             	pushl  -0x5c(%ebx)
80103b96:	68 8f 6d 10 80       	push   $0x80106d8f
80103b9b:	e8 80 ca ff ff       	call   80100620 <cprintf>
    if(p->state == SLEEPING){
80103ba0:	83 c4 20             	add    $0x20,%esp
80103ba3:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
80103ba7:	74 2f                	je     80103bd8 <procdump+0x6c>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103ba9:	83 ec 0c             	sub    $0xc,%esp
80103bac:	68 1b 71 10 80       	push   $0x8010711b
80103bb1:	e8 6a ca ff ff       	call   80100620 <cprintf>
80103bb6:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103bb9:	83 eb 80             	sub    $0xffffff80,%ebx
80103bbc:	81 fb a0 57 11 80    	cmp    $0x801157a0,%ebx
80103bc2:	74 50                	je     80103c14 <procdump+0xa8>
    if(p->state == UNUSED)
80103bc4:	8b 43 a0             	mov    -0x60(%ebx),%eax
80103bc7:	85 c0                	test   %eax,%eax
80103bc9:	74 ee                	je     80103bb9 <procdump+0x4d>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103bcb:	83 f8 05             	cmp    $0x5,%eax
80103bce:	76 b0                	jbe    80103b80 <procdump+0x14>
      state = "???";
80103bd0:	b8 8b 6d 10 80       	mov    $0x80106d8b,%eax
80103bd5:	eb b4                	jmp    80103b8b <procdump+0x1f>
80103bd7:	90                   	nop
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103bd8:	83 ec 08             	sub    $0x8,%esp
80103bdb:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103bde:	50                   	push   %eax
80103bdf:	8b 43 b0             	mov    -0x50(%ebx),%eax
80103be2:	8b 40 0c             	mov    0xc(%eax),%eax
80103be5:	83 c0 08             	add    $0x8,%eax
80103be8:	50                   	push   %eax
80103be9:	e8 3a 03 00 00       	call   80103f28 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103bee:	8d 7d c0             	lea    -0x40(%ebp),%edi
80103bf1:	83 c4 10             	add    $0x10,%esp
80103bf4:	8b 17                	mov    (%edi),%edx
80103bf6:	85 d2                	test   %edx,%edx
80103bf8:	74 af                	je     80103ba9 <procdump+0x3d>
        cprintf(" %p", pc[i]);
80103bfa:	83 ec 08             	sub    $0x8,%esp
80103bfd:	52                   	push   %edx
80103bfe:	68 e1 67 10 80       	push   $0x801067e1
80103c03:	e8 18 ca ff ff       	call   80100620 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103c08:	83 c7 04             	add    $0x4,%edi
80103c0b:	83 c4 10             	add    $0x10,%esp
80103c0e:	39 fe                	cmp    %edi,%esi
80103c10:	75 e2                	jne    80103bf4 <procdump+0x88>
80103c12:	eb 95                	jmp    80103ba9 <procdump+0x3d>
  }
}
80103c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103c17:	5b                   	pop    %ebx
80103c18:	5e                   	pop    %esi
80103c19:	5f                   	pop    %edi
80103c1a:	5d                   	pop    %ebp
80103c1b:	c3                   	ret    

80103c1c <sgenrand>:
static int mti=N+1; /* mti==N+1 means mt[N] is not initialized */

/* initializing the array with a NONZERO seed */
void
sgenrand(unsigned long seed)
{
80103c1c:	55                   	push   %ebp
80103c1d:	89 e5                	mov    %esp,%ebp
80103c1f:	8b 45 08             	mov    0x8(%ebp),%eax
    /* setting initial seeds to mt[N] using         */
    /* the generator Line 25 of Table 1 in          */
    /* [KNUTH 1981, The Art of Computer Programming */
    /*    Vol. 2 (2nd Ed.), pp102]                  */
    mt[0]= seed & 0xffffffff;
80103c22:	a3 c0 a5 10 80       	mov    %eax,0x8010a5c0
    for (mti=1; mti<N; mti++)
80103c27:	b9 c4 a5 10 80       	mov    $0x8010a5c4,%ecx
80103c2c:	eb 05                	jmp    80103c33 <sgenrand+0x17>
80103c2e:	66 90                	xchg   %ax,%ax
80103c30:	83 c1 04             	add    $0x4,%ecx
        mt[mti] = (69069 * mt[mti-1]) & 0xffffffff;
80103c33:	8d 14 00             	lea    (%eax,%eax,1),%edx
80103c36:	01 c2                	add    %eax,%edx
80103c38:	01 d2                	add    %edx,%edx
80103c3a:	01 c2                	add    %eax,%edx
80103c3c:	8d 14 90             	lea    (%eax,%edx,4),%edx
80103c3f:	8d 14 d2             	lea    (%edx,%edx,8),%edx
80103c42:	01 d2                	add    %edx,%edx
80103c44:	01 c2                	add    %eax,%edx
80103c46:	8d 04 90             	lea    (%eax,%edx,4),%eax
80103c49:	89 c2                	mov    %eax,%edx
80103c4b:	c1 e2 05             	shl    $0x5,%edx
80103c4e:	01 d0                	add    %edx,%eax
80103c50:	89 01                	mov    %eax,(%ecx)
    for (mti=1; mti<N; mti++)
80103c52:	81 f9 7c af 10 80    	cmp    $0x8010af7c,%ecx
80103c58:	75 d6                	jne    80103c30 <sgenrand+0x14>
80103c5a:	c7 05 08 a0 10 80 70 	movl   $0x270,0x8010a008
80103c61:	02 00 00 
}
80103c64:	5d                   	pop    %ebp
80103c65:	c3                   	ret    
80103c66:	66 90                	xchg   %ax,%ax

80103c68 <genrand>:

long /* for integer generation */
genrand()
{
80103c68:	55                   	push   %ebp
80103c69:	89 e5                	mov    %esp,%ebp
80103c6b:	53                   	push   %ebx
    unsigned long y;
    static unsigned long mag01[2]={0x0, MATRIX_A};
    /* mag01[x] = x * MATRIX_A  for x=0,1 */

    if (mti >= N) { /* generate N words at one time */
80103c6c:	a1 08 a0 10 80       	mov    0x8010a008,%eax
80103c71:	3d 6f 02 00 00       	cmp    $0x26f,%eax
80103c76:	7f 3e                	jg     80103cb6 <genrand+0x4e>
80103c78:	8d 50 01             	lea    0x1(%eax),%edx
80103c7b:	8b 04 85 c0 a5 10 80 	mov    -0x7fef5a40(,%eax,4),%eax
        mt[N-1] = mt[M-1] ^ (y >> 1) ^ mag01[y & 0x1];

        mti = 0;
    }
  
    y = mt[mti++];
80103c82:	89 15 08 a0 10 80    	mov    %edx,0x8010a008
    y ^= TEMPERING_SHIFT_U(y);
80103c88:	89 c2                	mov    %eax,%edx
80103c8a:	c1 ea 0b             	shr    $0xb,%edx
80103c8d:	31 c2                	xor    %eax,%edx
    y ^= TEMPERING_SHIFT_S(y) & TEMPERING_MASK_B;
80103c8f:	89 d0                	mov    %edx,%eax
80103c91:	c1 e0 07             	shl    $0x7,%eax
80103c94:	25 80 56 2c 9d       	and    $0x9d2c5680,%eax
80103c99:	31 c2                	xor    %eax,%edx
    y ^= TEMPERING_SHIFT_T(y) & TEMPERING_MASK_C;
80103c9b:	89 d0                	mov    %edx,%eax
80103c9d:	c1 e0 0f             	shl    $0xf,%eax
80103ca0:	25 00 00 c6 ef       	and    $0xefc60000,%eax
80103ca5:	31 d0                	xor    %edx,%eax
    y ^= TEMPERING_SHIFT_L(y);
80103ca7:	89 c2                	mov    %eax,%edx
80103ca9:	c1 ea 12             	shr    $0x12,%edx
80103cac:	31 d0                	xor    %edx,%eax

    // Strip off uppermost bit because we want a long,
    // not an unsigned long
    return y & RAND_MAX;
80103cae:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
}
80103cb3:	5b                   	pop    %ebx
80103cb4:	5d                   	pop    %ebp
80103cb5:	c3                   	ret    
        if (mti == N+1)   /* if sgenrand() has not been called, */
80103cb6:	3d 71 02 00 00       	cmp    $0x271,%eax
80103cbb:	0f 84 c2 00 00 00    	je     80103d83 <genrand+0x11b>
    mt[0]= seed & 0xffffffff;
80103cc1:	31 c0                	xor    %eax,%eax
80103cc3:	90                   	nop
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
80103cc4:	8b 0c 85 c0 a5 10 80 	mov    -0x7fef5a40(,%eax,4),%ecx
80103ccb:	81 e1 00 00 00 80    	and    $0x80000000,%ecx
80103cd1:	40                   	inc    %eax
80103cd2:	8b 14 85 c0 a5 10 80 	mov    -0x7fef5a40(,%eax,4),%edx
80103cd9:	81 e2 ff ff ff 7f    	and    $0x7fffffff,%edx
80103cdf:	09 ca                	or     %ecx,%edx
            mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 0x1];
80103ce1:	89 d1                	mov    %edx,%ecx
80103ce3:	d1 e9                	shr    %ecx
80103ce5:	33 0c 85 f0 ab 10 80 	xor    -0x7fef5410(,%eax,4),%ecx
80103cec:	83 e2 01             	and    $0x1,%edx
80103cef:	33 0c 95 04 6e 10 80 	xor    -0x7fef91fc(,%edx,4),%ecx
80103cf6:	89 0c 85 bc a5 10 80 	mov    %ecx,-0x7fef5a44(,%eax,4)
        for (kk=0;kk<N-M;kk++) {
80103cfd:	3d e3 00 00 00       	cmp    $0xe3,%eax
80103d02:	75 c0                	jne    80103cc4 <genrand+0x5c>
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
80103d04:	8b 0c 85 c0 a5 10 80 	mov    -0x7fef5a40(,%eax,4),%ecx
80103d0b:	81 e1 00 00 00 80    	and    $0x80000000,%ecx
80103d11:	40                   	inc    %eax
80103d12:	8b 14 85 c0 a5 10 80 	mov    -0x7fef5a40(,%eax,4),%edx
80103d19:	81 e2 ff ff ff 7f    	and    $0x7fffffff,%edx
80103d1f:	09 ca                	or     %ecx,%edx
            mt[kk] = mt[kk+(M-N)] ^ (y >> 1) ^ mag01[y & 0x1];
80103d21:	89 d1                	mov    %edx,%ecx
80103d23:	d1 e9                	shr    %ecx
80103d25:	33 0c 85 30 a2 10 80 	xor    -0x7fef5dd0(,%eax,4),%ecx
80103d2c:	83 e2 01             	and    $0x1,%edx
80103d2f:	33 0c 95 04 6e 10 80 	xor    -0x7fef91fc(,%edx,4),%ecx
80103d36:	89 0c 85 bc a5 10 80 	mov    %ecx,-0x7fef5a44(,%eax,4)
        for (;kk<N-1;kk++) {
80103d3d:	3d 6f 02 00 00       	cmp    $0x26f,%eax
80103d42:	75 c0                	jne    80103d04 <genrand+0x9c>
        y = (mt[N-1]&UPPER_MASK)|(mt[0]&LOWER_MASK);
80103d44:	a1 c0 a5 10 80       	mov    0x8010a5c0,%eax
80103d49:	8b 0d 7c af 10 80    	mov    0x8010af7c,%ecx
80103d4f:	81 e1 00 00 00 80    	and    $0x80000000,%ecx
80103d55:	89 c2                	mov    %eax,%edx
80103d57:	81 e2 ff ff ff 7f    	and    $0x7fffffff,%edx
80103d5d:	09 d1                	or     %edx,%ecx
        mt[N-1] = mt[M-1] ^ (y >> 1) ^ mag01[y & 0x1];
80103d5f:	89 ca                	mov    %ecx,%edx
80103d61:	d1 ea                	shr    %edx
80103d63:	33 15 f0 ab 10 80    	xor    0x8010abf0,%edx
80103d69:	83 e1 01             	and    $0x1,%ecx
80103d6c:	33 14 8d 04 6e 10 80 	xor    -0x7fef91fc(,%ecx,4),%edx
80103d73:	89 15 7c af 10 80    	mov    %edx,0x8010af7c
80103d79:	ba 01 00 00 00       	mov    $0x1,%edx
80103d7e:	e9 ff fe ff ff       	jmp    80103c82 <genrand+0x1a>
    mt[0]= seed & 0xffffffff;
80103d83:	c7 05 c0 a5 10 80 05 	movl   $0x1105,0x8010a5c0
80103d8a:	11 00 00 
    for (mti=1; mti<N; mti++)
80103d8d:	b9 c4 a5 10 80       	mov    $0x8010a5c4,%ecx
80103d92:	bb 7c af 10 80       	mov    $0x8010af7c,%ebx
    mt[0]= seed & 0xffffffff;
80103d97:	b8 05 11 00 00       	mov    $0x1105,%eax
80103d9c:	eb 05                	jmp    80103da3 <genrand+0x13b>
80103d9e:	66 90                	xchg   %ax,%ax
80103da0:	83 c1 04             	add    $0x4,%ecx
        mt[mti] = (69069 * mt[mti-1]) & 0xffffffff;
80103da3:	8d 14 00             	lea    (%eax,%eax,1),%edx
80103da6:	01 c2                	add    %eax,%edx
80103da8:	01 d2                	add    %edx,%edx
80103daa:	01 c2                	add    %eax,%edx
80103dac:	8d 14 90             	lea    (%eax,%edx,4),%edx
80103daf:	8d 14 d2             	lea    (%edx,%edx,8),%edx
80103db2:	01 d2                	add    %edx,%edx
80103db4:	01 c2                	add    %eax,%edx
80103db6:	8d 04 90             	lea    (%eax,%edx,4),%eax
80103db9:	89 c2                	mov    %eax,%edx
80103dbb:	c1 e2 05             	shl    $0x5,%edx
80103dbe:	01 d0                	add    %edx,%eax
80103dc0:	89 01                	mov    %eax,(%ecx)
    for (mti=1; mti<N; mti++)
80103dc2:	39 cb                	cmp    %ecx,%ebx
80103dc4:	75 da                	jne    80103da0 <genrand+0x138>
80103dc6:	e9 f6 fe ff ff       	jmp    80103cc1 <genrand+0x59>
80103dcb:	90                   	nop

80103dcc <random_at_most>:

// Assumes 0 <= max <= RAND_MAX
// Returns in the half-open interval [0, max]
long random_at_most(long max) {
80103dcc:	55                   	push   %ebp
80103dcd:	89 e5                	mov    %esp,%ebp
80103dcf:	56                   	push   %esi
80103dd0:	53                   	push   %ebx
  unsigned long
    // max <= RAND_MAX < ULONG_MAX, so this is okay.
    num_bins = (unsigned long) max + 1,
80103dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd4:	8d 48 01             	lea    0x1(%eax),%ecx
    num_rand = (unsigned long) RAND_MAX + 1,
    bin_size = num_rand / num_bins,
80103dd7:	bb 00 00 00 80       	mov    $0x80000000,%ebx
80103ddc:	89 d8                	mov    %ebx,%eax
80103dde:	31 d2                	xor    %edx,%edx
80103de0:	f7 f1                	div    %ecx
80103de2:	89 c6                	mov    %eax,%esi
80103de4:	29 d3                	sub    %edx,%ebx
80103de6:	66 90                	xchg   %ax,%ax
    defect   = num_rand % num_bins;

  long x;
  do {
   x = genrand();
80103de8:	e8 7b fe ff ff       	call   80103c68 <genrand>
  }
  // This is carefully written not to overflow
  while (num_rand - defect <= (unsigned long)x);
80103ded:	39 d8                	cmp    %ebx,%eax
80103def:	73 f7                	jae    80103de8 <random_at_most+0x1c>

  // Truncated division is intentional
  return x/bin_size;
80103df1:	31 d2                	xor    %edx,%edx
80103df3:	f7 f6                	div    %esi
}
80103df5:	5b                   	pop    %ebx
80103df6:	5e                   	pop    %esi
80103df7:	5d                   	pop    %ebp
80103df8:	c3                   	ret    
80103df9:	66 90                	xchg   %ax,%ax
80103dfb:	90                   	nop

80103dfc <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103dfc:	55                   	push   %ebp
80103dfd:	89 e5                	mov    %esp,%ebp
80103dff:	53                   	push   %ebx
80103e00:	83 ec 0c             	sub    $0xc,%esp
80103e03:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103e06:	68 0c 6e 10 80       	push   $0x80106e0c
80103e0b:	8d 43 04             	lea    0x4(%ebx),%eax
80103e0e:	50                   	push   %eax
80103e0f:	e8 f8 00 00 00       	call   80103f0c <initlock>
  lk->name = name;
80103e14:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e17:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103e1a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103e20:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103e27:	83 c4 10             	add    $0x10,%esp
80103e2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e2d:	c9                   	leave  
80103e2e:	c3                   	ret    
80103e2f:	90                   	nop

80103e30 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103e30:	55                   	push   %ebp
80103e31:	89 e5                	mov    %esp,%ebp
80103e33:	56                   	push   %esi
80103e34:	53                   	push   %ebx
80103e35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103e38:	8d 73 04             	lea    0x4(%ebx),%esi
80103e3b:	83 ec 0c             	sub    $0xc,%esp
80103e3e:	56                   	push   %esi
80103e3f:	e8 08 02 00 00       	call   8010404c <acquire>
  while (lk->locked) {
80103e44:	83 c4 10             	add    $0x10,%esp
80103e47:	8b 13                	mov    (%ebx),%edx
80103e49:	85 d2                	test   %edx,%edx
80103e4b:	74 16                	je     80103e63 <acquiresleep+0x33>
80103e4d:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
80103e50:	83 ec 08             	sub    $0x8,%esp
80103e53:	56                   	push   %esi
80103e54:	53                   	push   %ebx
80103e55:	e8 96 fa ff ff       	call   801038f0 <sleep>
  while (lk->locked) {
80103e5a:	83 c4 10             	add    $0x10,%esp
80103e5d:	8b 03                	mov    (%ebx),%eax
80103e5f:	85 c0                	test   %eax,%eax
80103e61:	75 ed                	jne    80103e50 <acquiresleep+0x20>
  }
  lk->locked = 1;
80103e63:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103e69:	e8 f2 f4 ff ff       	call   80103360 <myproc>
80103e6e:	8b 40 10             	mov    0x10(%eax),%eax
80103e71:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103e74:	89 75 08             	mov    %esi,0x8(%ebp)
}
80103e77:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103e7a:	5b                   	pop    %ebx
80103e7b:	5e                   	pop    %esi
80103e7c:	5d                   	pop    %ebp
  release(&lk->lk);
80103e7d:	e9 62 02 00 00       	jmp    801040e4 <release>
80103e82:	66 90                	xchg   %ax,%ax

80103e84 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103e84:	55                   	push   %ebp
80103e85:	89 e5                	mov    %esp,%ebp
80103e87:	56                   	push   %esi
80103e88:	53                   	push   %ebx
80103e89:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103e8c:	8d 73 04             	lea    0x4(%ebx),%esi
80103e8f:	83 ec 0c             	sub    $0xc,%esp
80103e92:	56                   	push   %esi
80103e93:	e8 b4 01 00 00       	call   8010404c <acquire>
  lk->locked = 0;
80103e98:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103e9e:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103ea5:	89 1c 24             	mov    %ebx,(%esp)
80103ea8:	e8 ef fb ff ff       	call   80103a9c <wakeup>
  release(&lk->lk);
80103ead:	83 c4 10             	add    $0x10,%esp
80103eb0:	89 75 08             	mov    %esi,0x8(%ebp)
}
80103eb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103eb6:	5b                   	pop    %ebx
80103eb7:	5e                   	pop    %esi
80103eb8:	5d                   	pop    %ebp
  release(&lk->lk);
80103eb9:	e9 26 02 00 00       	jmp    801040e4 <release>
80103ebe:	66 90                	xchg   %ax,%ax

80103ec0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103ec0:	55                   	push   %ebp
80103ec1:	89 e5                	mov    %esp,%ebp
80103ec3:	56                   	push   %esi
80103ec4:	53                   	push   %ebx
80103ec5:	83 ec 1c             	sub    $0x1c,%esp
80103ec8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103ecb:	8d 73 04             	lea    0x4(%ebx),%esi
80103ece:	56                   	push   %esi
80103ecf:	e8 78 01 00 00       	call   8010404c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103ed4:	83 c4 10             	add    $0x10,%esp
80103ed7:	8b 03                	mov    (%ebx),%eax
80103ed9:	85 c0                	test   %eax,%eax
80103edb:	75 1b                	jne    80103ef8 <holdingsleep+0x38>
80103edd:	31 c0                	xor    %eax,%eax
80103edf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80103ee2:	83 ec 0c             	sub    $0xc,%esp
80103ee5:	56                   	push   %esi
80103ee6:	e8 f9 01 00 00       	call   801040e4 <release>
  return r;
}
80103eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eee:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ef1:	5b                   	pop    %ebx
80103ef2:	5e                   	pop    %esi
80103ef3:	5d                   	pop    %ebp
80103ef4:	c3                   	ret    
80103ef5:	8d 76 00             	lea    0x0(%esi),%esi
  r = lk->locked && (lk->pid == myproc()->pid);
80103ef8:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103efb:	e8 60 f4 ff ff       	call   80103360 <myproc>
80103f00:	39 58 10             	cmp    %ebx,0x10(%eax)
80103f03:	0f 94 c0             	sete   %al
80103f06:	0f b6 c0             	movzbl %al,%eax
80103f09:	eb d4                	jmp    80103edf <holdingsleep+0x1f>
80103f0b:	90                   	nop

80103f0c <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103f0c:	55                   	push   %ebp
80103f0d:	89 e5                	mov    %esp,%ebp
80103f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103f12:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f15:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103f18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103f1e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103f25:	5d                   	pop    %ebp
80103f26:	c3                   	ret    
80103f27:	90                   	nop

80103f28 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103f28:	55                   	push   %ebp
80103f29:	89 e5                	mov    %esp,%ebp
80103f2b:	53                   	push   %ebx
80103f2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f32:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
80103f35:	31 d2                	xor    %edx,%edx
80103f37:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103f38:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80103f3e:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103f44:	77 12                	ja     80103f58 <getcallerpcs+0x30>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103f46:	8b 58 04             	mov    0x4(%eax),%ebx
80103f49:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103f4c:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80103f4e:	42                   	inc    %edx
80103f4f:	83 fa 0a             	cmp    $0xa,%edx
80103f52:	75 e4                	jne    80103f38 <getcallerpcs+0x10>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
80103f54:	5b                   	pop    %ebx
80103f55:	5d                   	pop    %ebp
80103f56:	c3                   	ret    
80103f57:	90                   	nop
  for(; i < 10; i++)
80103f58:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80103f5b:	8d 51 28             	lea    0x28(%ecx),%edx
80103f5e:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80103f60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80103f66:	83 c0 04             	add    $0x4,%eax
80103f69:	39 d0                	cmp    %edx,%eax
80103f6b:	75 f3                	jne    80103f60 <getcallerpcs+0x38>
}
80103f6d:	5b                   	pop    %ebx
80103f6e:	5d                   	pop    %ebp
80103f6f:	c3                   	ret    

80103f70 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103f70:	55                   	push   %ebp
80103f71:	89 e5                	mov    %esp,%ebp
80103f73:	53                   	push   %ebx
80103f74:	52                   	push   %edx
80103f75:	9c                   	pushf  
80103f76:	5b                   	pop    %ebx
  asm volatile("cli");
80103f77:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103f78:	e8 4b f3 ff ff       	call   801032c8 <mycpu>
80103f7d:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103f83:	85 c9                	test   %ecx,%ecx
80103f85:	74 11                	je     80103f98 <pushcli+0x28>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103f87:	e8 3c f3 ff ff       	call   801032c8 <mycpu>
80103f8c:	ff 80 a4 00 00 00    	incl   0xa4(%eax)
}
80103f92:	58                   	pop    %eax
80103f93:	5b                   	pop    %ebx
80103f94:	5d                   	pop    %ebp
80103f95:	c3                   	ret    
80103f96:	66 90                	xchg   %ax,%ax
    mycpu()->intena = eflags & FL_IF;
80103f98:	e8 2b f3 ff ff       	call   801032c8 <mycpu>
80103f9d:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103fa3:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
  mycpu()->ncli += 1;
80103fa9:	e8 1a f3 ff ff       	call   801032c8 <mycpu>
80103fae:	ff 80 a4 00 00 00    	incl   0xa4(%eax)
}
80103fb4:	58                   	pop    %eax
80103fb5:	5b                   	pop    %ebx
80103fb6:	5d                   	pop    %ebp
80103fb7:	c3                   	ret    

80103fb8 <popcli>:

void
popcli(void)
{
80103fb8:	55                   	push   %ebp
80103fb9:	89 e5                	mov    %esp,%ebp
80103fbb:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103fbe:	9c                   	pushf  
80103fbf:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103fc0:	f6 c4 02             	test   $0x2,%ah
80103fc3:	75 31                	jne    80103ff6 <popcli+0x3e>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103fc5:	e8 fe f2 ff ff       	call   801032c8 <mycpu>
80103fca:	ff 88 a4 00 00 00    	decl   0xa4(%eax)
80103fd0:	78 31                	js     80104003 <popcli+0x4b>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103fd2:	e8 f1 f2 ff ff       	call   801032c8 <mycpu>
80103fd7:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80103fdd:	85 d2                	test   %edx,%edx
80103fdf:	74 03                	je     80103fe4 <popcli+0x2c>
    sti();
}
80103fe1:	c9                   	leave  
80103fe2:	c3                   	ret    
80103fe3:	90                   	nop
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103fe4:	e8 df f2 ff ff       	call   801032c8 <mycpu>
80103fe9:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103fef:	85 c0                	test   %eax,%eax
80103ff1:	74 ee                	je     80103fe1 <popcli+0x29>
  asm volatile("sti");
80103ff3:	fb                   	sti    
}
80103ff4:	c9                   	leave  
80103ff5:	c3                   	ret    
    panic("popcli - interruptible");
80103ff6:	83 ec 0c             	sub    $0xc,%esp
80103ff9:	68 17 6e 10 80       	push   $0x80106e17
80103ffe:	e8 3d c3 ff ff       	call   80100340 <panic>
    panic("popcli");
80104003:	83 ec 0c             	sub    $0xc,%esp
80104006:	68 2e 6e 10 80       	push   $0x80106e2e
8010400b:	e8 30 c3 ff ff       	call   80100340 <panic>

80104010 <holding>:
{
80104010:	55                   	push   %ebp
80104011:	89 e5                	mov    %esp,%ebp
80104013:	53                   	push   %ebx
80104014:	83 ec 14             	sub    $0x14,%esp
80104017:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
8010401a:	e8 51 ff ff ff       	call   80103f70 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010401f:	8b 03                	mov    (%ebx),%eax
80104021:	85 c0                	test   %eax,%eax
80104023:	75 13                	jne    80104038 <holding+0x28>
80104025:	31 c0                	xor    %eax,%eax
80104027:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
8010402a:	e8 89 ff ff ff       	call   80103fb8 <popcli>
}
8010402f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104032:	83 c4 14             	add    $0x14,%esp
80104035:	5b                   	pop    %ebx
80104036:	5d                   	pop    %ebp
80104037:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80104038:	8b 5b 08             	mov    0x8(%ebx),%ebx
8010403b:	e8 88 f2 ff ff       	call   801032c8 <mycpu>
80104040:	39 c3                	cmp    %eax,%ebx
80104042:	0f 94 c0             	sete   %al
80104045:	0f b6 c0             	movzbl %al,%eax
80104048:	eb dd                	jmp    80104027 <holding+0x17>
8010404a:	66 90                	xchg   %ax,%ax

8010404c <acquire>:
{
8010404c:	55                   	push   %ebp
8010404d:	89 e5                	mov    %esp,%ebp
8010404f:	56                   	push   %esi
80104050:	53                   	push   %ebx
  pushcli(); // disable interrupts to avoid deadlock.
80104051:	e8 1a ff ff ff       	call   80103f70 <pushcli>
  if(holding(lk))
80104056:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104059:	83 ec 0c             	sub    $0xc,%esp
8010405c:	53                   	push   %ebx
8010405d:	e8 ae ff ff ff       	call   80104010 <holding>
80104062:	83 c4 10             	add    $0x10,%esp
80104065:	85 c0                	test   %eax,%eax
80104067:	75 6b                	jne    801040d4 <acquire+0x88>
80104069:	89 c6                	mov    %eax,%esi
  asm volatile("lock; xchgl %0, %1" :
8010406b:	ba 01 00 00 00       	mov    $0x1,%edx
80104070:	eb 05                	jmp    80104077 <acquire+0x2b>
80104072:	66 90                	xchg   %ax,%ax
80104074:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104077:	89 d0                	mov    %edx,%eax
80104079:	f0 87 03             	lock xchg %eax,(%ebx)
  while(xchg(&lk->locked, 1) != 0)
8010407c:	85 c0                	test   %eax,%eax
8010407e:	75 f4                	jne    80104074 <acquire+0x28>
  __sync_synchronize();
80104080:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104085:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104088:	e8 3b f2 ff ff       	call   801032c8 <mycpu>
8010408d:	89 43 08             	mov    %eax,0x8(%ebx)
  ebp = (uint*)v - 2;
80104090:	89 e8                	mov    %ebp,%eax
80104092:	66 90                	xchg   %ax,%ax
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104094:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010409a:	81 fa fe ff ff 7f    	cmp    $0x7ffffffe,%edx
801040a0:	77 16                	ja     801040b8 <acquire+0x6c>
    pcs[i] = ebp[1];     // saved %eip
801040a2:	8b 50 04             	mov    0x4(%eax),%edx
801040a5:	89 54 b3 0c          	mov    %edx,0xc(%ebx,%esi,4)
    ebp = (uint*)ebp[0]; // saved %ebp
801040a9:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
801040ab:	46                   	inc    %esi
801040ac:	83 fe 0a             	cmp    $0xa,%esi
801040af:	75 e3                	jne    80104094 <acquire+0x48>
}
801040b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040b4:	5b                   	pop    %ebx
801040b5:	5e                   	pop    %esi
801040b6:	5d                   	pop    %ebp
801040b7:	c3                   	ret    
  for(; i < 10; i++)
801040b8:	8d 44 b3 0c          	lea    0xc(%ebx,%esi,4),%eax
801040bc:	83 c3 34             	add    $0x34,%ebx
801040bf:	90                   	nop
    pcs[i] = 0;
801040c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801040c6:	83 c0 04             	add    $0x4,%eax
801040c9:	39 d8                	cmp    %ebx,%eax
801040cb:	75 f3                	jne    801040c0 <acquire+0x74>
}
801040cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040d0:	5b                   	pop    %ebx
801040d1:	5e                   	pop    %esi
801040d2:	5d                   	pop    %ebp
801040d3:	c3                   	ret    
    panic("acquire");
801040d4:	83 ec 0c             	sub    $0xc,%esp
801040d7:	68 35 6e 10 80       	push   $0x80106e35
801040dc:	e8 5f c2 ff ff       	call   80100340 <panic>
801040e1:	8d 76 00             	lea    0x0(%esi),%esi

801040e4 <release>:
{
801040e4:	55                   	push   %ebp
801040e5:	89 e5                	mov    %esp,%ebp
801040e7:	53                   	push   %ebx
801040e8:	83 ec 10             	sub    $0x10,%esp
801040eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
801040ee:	53                   	push   %ebx
801040ef:	e8 1c ff ff ff       	call   80104010 <holding>
801040f4:	83 c4 10             	add    $0x10,%esp
801040f7:	85 c0                	test   %eax,%eax
801040f9:	74 22                	je     8010411d <release+0x39>
  lk->pcs[0] = 0;
801040fb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104102:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80104109:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010410e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
80104114:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104117:	c9                   	leave  
  popcli();
80104118:	e9 9b fe ff ff       	jmp    80103fb8 <popcli>
    panic("release");
8010411d:	83 ec 0c             	sub    $0xc,%esp
80104120:	68 3d 6e 10 80       	push   $0x80106e3d
80104125:	e8 16 c2 ff ff       	call   80100340 <panic>
8010412a:	66 90                	xchg   %ax,%ax

8010412c <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010412c:	55                   	push   %ebp
8010412d:	89 e5                	mov    %esp,%ebp
8010412f:	57                   	push   %edi
80104130:	53                   	push   %ebx
80104131:	8b 55 08             	mov    0x8(%ebp),%edx
80104134:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80104137:	89 d0                	mov    %edx,%eax
80104139:	09 c8                	or     %ecx,%eax
8010413b:	a8 03                	test   $0x3,%al
8010413d:	75 29                	jne    80104168 <memset+0x3c>
    c &= 0xFF;
8010413f:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104143:	c1 e9 02             	shr    $0x2,%ecx
80104146:	8b 45 0c             	mov    0xc(%ebp),%eax
80104149:	c1 e0 18             	shl    $0x18,%eax
8010414c:	89 fb                	mov    %edi,%ebx
8010414e:	c1 e3 10             	shl    $0x10,%ebx
80104151:	09 d8                	or     %ebx,%eax
80104153:	09 f8                	or     %edi,%eax
80104155:	c1 e7 08             	shl    $0x8,%edi
80104158:	09 f8                	or     %edi,%eax
}

static inline void
stosl(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosl" :
8010415a:	89 d7                	mov    %edx,%edi
8010415c:	fc                   	cld    
8010415d:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
8010415f:	89 d0                	mov    %edx,%eax
80104161:	5b                   	pop    %ebx
80104162:	5f                   	pop    %edi
80104163:	5d                   	pop    %ebp
80104164:	c3                   	ret    
80104165:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("cld; rep stosb" :
80104168:	89 d7                	mov    %edx,%edi
8010416a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010416d:	fc                   	cld    
8010416e:	f3 aa                	rep stos %al,%es:(%edi)
80104170:	89 d0                	mov    %edx,%eax
80104172:	5b                   	pop    %ebx
80104173:	5f                   	pop    %edi
80104174:	5d                   	pop    %ebp
80104175:	c3                   	ret    
80104176:	66 90                	xchg   %ax,%ax

80104178 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104178:	55                   	push   %ebp
80104179:	89 e5                	mov    %esp,%ebp
8010417b:	56                   	push   %esi
8010417c:	53                   	push   %ebx
8010417d:	8b 55 08             	mov    0x8(%ebp),%edx
80104180:	8b 45 0c             	mov    0xc(%ebp),%eax
80104183:	8b 75 10             	mov    0x10(%ebp),%esi
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104186:	85 f6                	test   %esi,%esi
80104188:	74 1e                	je     801041a8 <memcmp+0x30>
8010418a:	01 c6                	add    %eax,%esi
8010418c:	eb 08                	jmp    80104196 <memcmp+0x1e>
8010418e:	66 90                	xchg   %ax,%ax
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104190:	42                   	inc    %edx
80104191:	40                   	inc    %eax
  while(n-- > 0){
80104192:	39 f0                	cmp    %esi,%eax
80104194:	74 12                	je     801041a8 <memcmp+0x30>
    if(*s1 != *s2)
80104196:	8a 0a                	mov    (%edx),%cl
80104198:	0f b6 18             	movzbl (%eax),%ebx
8010419b:	38 d9                	cmp    %bl,%cl
8010419d:	74 f1                	je     80104190 <memcmp+0x18>
      return *s1 - *s2;
8010419f:	0f b6 c1             	movzbl %cl,%eax
801041a2:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
801041a4:	5b                   	pop    %ebx
801041a5:	5e                   	pop    %esi
801041a6:	5d                   	pop    %ebp
801041a7:	c3                   	ret    
  return 0;
801041a8:	31 c0                	xor    %eax,%eax
}
801041aa:	5b                   	pop    %ebx
801041ab:	5e                   	pop    %esi
801041ac:	5d                   	pop    %ebp
801041ad:	c3                   	ret    
801041ae:	66 90                	xchg   %ax,%ax

801041b0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801041b0:	55                   	push   %ebp
801041b1:	89 e5                	mov    %esp,%ebp
801041b3:	57                   	push   %edi
801041b4:	56                   	push   %esi
801041b5:	8b 55 08             	mov    0x8(%ebp),%edx
801041b8:	8b 75 0c             	mov    0xc(%ebp),%esi
801041bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801041be:	39 d6                	cmp    %edx,%esi
801041c0:	73 07                	jae    801041c9 <memmove+0x19>
801041c2:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
801041c5:	39 fa                	cmp    %edi,%edx
801041c7:	72 17                	jb     801041e0 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801041c9:	85 c9                	test   %ecx,%ecx
801041cb:	74 0c                	je     801041d9 <memmove+0x29>
801041cd:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
801041d0:	89 d7                	mov    %edx,%edi
801041d2:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
801041d4:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
801041d5:	39 f0                	cmp    %esi,%eax
801041d7:	75 fb                	jne    801041d4 <memmove+0x24>

  return dst;
}
801041d9:	89 d0                	mov    %edx,%eax
801041db:	5e                   	pop    %esi
801041dc:	5f                   	pop    %edi
801041dd:	5d                   	pop    %ebp
801041de:	c3                   	ret    
801041df:	90                   	nop
801041e0:	8d 41 ff             	lea    -0x1(%ecx),%eax
    while(n-- > 0)
801041e3:	85 c9                	test   %ecx,%ecx
801041e5:	74 f2                	je     801041d9 <memmove+0x29>
801041e7:	90                   	nop
      *--d = *--s;
801041e8:	8a 0c 06             	mov    (%esi,%eax,1),%cl
801041eb:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
801041ee:	48                   	dec    %eax
801041ef:	83 f8 ff             	cmp    $0xffffffff,%eax
801041f2:	75 f4                	jne    801041e8 <memmove+0x38>
}
801041f4:	89 d0                	mov    %edx,%eax
801041f6:	5e                   	pop    %esi
801041f7:	5f                   	pop    %edi
801041f8:	5d                   	pop    %ebp
801041f9:	c3                   	ret    
801041fa:	66 90                	xchg   %ax,%ax

801041fc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
801041fc:	eb b2                	jmp    801041b0 <memmove>
801041fe:	66 90                	xchg   %ax,%ax

80104200 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104200:	55                   	push   %ebp
80104201:	89 e5                	mov    %esp,%ebp
80104203:	56                   	push   %esi
80104204:	53                   	push   %ebx
80104205:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104208:	8b 45 0c             	mov    0xc(%ebp),%eax
8010420b:	8b 75 10             	mov    0x10(%ebp),%esi
  while(n > 0 && *p && *p == *q)
8010420e:	85 f6                	test   %esi,%esi
80104210:	74 22                	je     80104234 <strncmp+0x34>
80104212:	01 c6                	add    %eax,%esi
80104214:	eb 0c                	jmp    80104222 <strncmp+0x22>
80104216:	66 90                	xchg   %ax,%ax
80104218:	38 ca                	cmp    %cl,%dl
8010421a:	75 0f                	jne    8010422b <strncmp+0x2b>
    n--, p++, q++;
8010421c:	43                   	inc    %ebx
8010421d:	40                   	inc    %eax
  while(n > 0 && *p && *p == *q)
8010421e:	39 f0                	cmp    %esi,%eax
80104220:	74 12                	je     80104234 <strncmp+0x34>
80104222:	8a 13                	mov    (%ebx),%dl
80104224:	0f b6 08             	movzbl (%eax),%ecx
80104227:	84 d2                	test   %dl,%dl
80104229:	75 ed                	jne    80104218 <strncmp+0x18>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
8010422b:	0f b6 c2             	movzbl %dl,%eax
8010422e:	29 c8                	sub    %ecx,%eax
}
80104230:	5b                   	pop    %ebx
80104231:	5e                   	pop    %esi
80104232:	5d                   	pop    %ebp
80104233:	c3                   	ret    
    return 0;
80104234:	31 c0                	xor    %eax,%eax
}
80104236:	5b                   	pop    %ebx
80104237:	5e                   	pop    %esi
80104238:	5d                   	pop    %ebp
80104239:	c3                   	ret    
8010423a:	66 90                	xchg   %ax,%ax

8010423c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010423c:	55                   	push   %ebp
8010423d:	89 e5                	mov    %esp,%ebp
8010423f:	56                   	push   %esi
80104240:	53                   	push   %ebx
80104241:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104244:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104247:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010424a:	eb 0c                	jmp    80104258 <strncpy+0x1c>
8010424c:	43                   	inc    %ebx
8010424d:	41                   	inc    %ecx
8010424e:	8a 43 ff             	mov    -0x1(%ebx),%al
80104251:	88 41 ff             	mov    %al,-0x1(%ecx)
80104254:	84 c0                	test   %al,%al
80104256:	74 07                	je     8010425f <strncpy+0x23>
80104258:	89 d6                	mov    %edx,%esi
8010425a:	4a                   	dec    %edx
8010425b:	85 f6                	test   %esi,%esi
8010425d:	7f ed                	jg     8010424c <strncpy+0x10>
    ;
  while(n-- > 0)
8010425f:	89 cb                	mov    %ecx,%ebx
80104261:	85 d2                	test   %edx,%edx
80104263:	7e 14                	jle    80104279 <strncpy+0x3d>
80104265:	8d 76 00             	lea    0x0(%esi),%esi
    *s++ = 0;
80104268:	43                   	inc    %ebx
80104269:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
  while(n-- > 0)
8010426d:	89 da                	mov    %ebx,%edx
8010426f:	f7 d2                	not    %edx
80104271:	01 ca                	add    %ecx,%edx
80104273:	01 f2                	add    %esi,%edx
80104275:	85 d2                	test   %edx,%edx
80104277:	7f ef                	jg     80104268 <strncpy+0x2c>
  return os;
}
80104279:	8b 45 08             	mov    0x8(%ebp),%eax
8010427c:	5b                   	pop    %ebx
8010427d:	5e                   	pop    %esi
8010427e:	5d                   	pop    %ebp
8010427f:	c3                   	ret    

80104280 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104280:	55                   	push   %ebp
80104281:	89 e5                	mov    %esp,%ebp
80104283:	56                   	push   %esi
80104284:	53                   	push   %ebx
80104285:	8b 45 08             	mov    0x8(%ebp),%eax
80104288:	8b 55 0c             	mov    0xc(%ebp),%edx
8010428b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  if(n <= 0)
8010428e:	85 c9                	test   %ecx,%ecx
80104290:	7e 1d                	jle    801042af <safestrcpy+0x2f>
80104292:	8d 74 0a ff          	lea    -0x1(%edx,%ecx,1),%esi
80104296:	89 c1                	mov    %eax,%ecx
80104298:	eb 0e                	jmp    801042a8 <safestrcpy+0x28>
8010429a:	66 90                	xchg   %ax,%ax
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
8010429c:	42                   	inc    %edx
8010429d:	41                   	inc    %ecx
8010429e:	8a 5a ff             	mov    -0x1(%edx),%bl
801042a1:	88 59 ff             	mov    %bl,-0x1(%ecx)
801042a4:	84 db                	test   %bl,%bl
801042a6:	74 04                	je     801042ac <safestrcpy+0x2c>
801042a8:	39 f2                	cmp    %esi,%edx
801042aa:	75 f0                	jne    8010429c <safestrcpy+0x1c>
    ;
  *s = 0;
801042ac:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
801042af:	5b                   	pop    %ebx
801042b0:	5e                   	pop    %esi
801042b1:	5d                   	pop    %ebp
801042b2:	c3                   	ret    
801042b3:	90                   	nop

801042b4 <strlen>:

int
strlen(const char *s)
{
801042b4:	55                   	push   %ebp
801042b5:	89 e5                	mov    %esp,%ebp
801042b7:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
801042ba:	31 c0                	xor    %eax,%eax
801042bc:	80 3a 00             	cmpb   $0x0,(%edx)
801042bf:	74 0a                	je     801042cb <strlen+0x17>
801042c1:	8d 76 00             	lea    0x0(%esi),%esi
801042c4:	40                   	inc    %eax
801042c5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801042c9:	75 f9                	jne    801042c4 <strlen+0x10>
    ;
  return n;
}
801042cb:	5d                   	pop    %ebp
801042cc:	c3                   	ret    

801042cd <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801042cd:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801042d1:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801042d5:	55                   	push   %ebp
  pushl %ebx
801042d6:	53                   	push   %ebx
  pushl %esi
801042d7:	56                   	push   %esi
  pushl %edi
801042d8:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801042d9:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801042db:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801042dd:	5f                   	pop    %edi
  popl %esi
801042de:	5e                   	pop    %esi
  popl %ebx
801042df:	5b                   	pop    %ebx
  popl %ebp
801042e0:	5d                   	pop    %ebp
  ret
801042e1:	c3                   	ret    
801042e2:	66 90                	xchg   %ax,%ax

801042e4 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801042e4:	55                   	push   %ebp
801042e5:	89 e5                	mov    %esp,%ebp
801042e7:	53                   	push   %ebx
801042e8:	51                   	push   %ecx
801042e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801042ec:	e8 6f f0 ff ff       	call   80103360 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801042f1:	8b 00                	mov    (%eax),%eax
801042f3:	39 d8                	cmp    %ebx,%eax
801042f5:	76 15                	jbe    8010430c <fetchint+0x28>
801042f7:	8d 53 04             	lea    0x4(%ebx),%edx
801042fa:	39 d0                	cmp    %edx,%eax
801042fc:	72 0e                	jb     8010430c <fetchint+0x28>
    return -1;
  *ip = *(int*)(addr);
801042fe:	8b 13                	mov    (%ebx),%edx
80104300:	8b 45 0c             	mov    0xc(%ebp),%eax
80104303:	89 10                	mov    %edx,(%eax)
  return 0;
80104305:	31 c0                	xor    %eax,%eax
}
80104307:	5a                   	pop    %edx
80104308:	5b                   	pop    %ebx
80104309:	5d                   	pop    %ebp
8010430a:	c3                   	ret    
8010430b:	90                   	nop
    return -1;
8010430c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104311:	eb f4                	jmp    80104307 <fetchint+0x23>
80104313:	90                   	nop

80104314 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104314:	55                   	push   %ebp
80104315:	89 e5                	mov    %esp,%ebp
80104317:	53                   	push   %ebx
80104318:	51                   	push   %ecx
80104319:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
8010431c:	e8 3f f0 ff ff       	call   80103360 <myproc>

  if(addr >= curproc->sz)
80104321:	39 18                	cmp    %ebx,(%eax)
80104323:	76 1f                	jbe    80104344 <fetchstr+0x30>
    return -1;
  *pp = (char*)addr;
80104325:	8b 55 0c             	mov    0xc(%ebp),%edx
80104328:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
8010432a:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
8010432c:	39 d3                	cmp    %edx,%ebx
8010432e:	73 14                	jae    80104344 <fetchstr+0x30>
80104330:	89 d8                	mov    %ebx,%eax
80104332:	eb 05                	jmp    80104339 <fetchstr+0x25>
80104334:	40                   	inc    %eax
80104335:	39 c2                	cmp    %eax,%edx
80104337:	76 0b                	jbe    80104344 <fetchstr+0x30>
    if(*s == 0)
80104339:	80 38 00             	cmpb   $0x0,(%eax)
8010433c:	75 f6                	jne    80104334 <fetchstr+0x20>
      return s - *pp;
8010433e:	29 d8                	sub    %ebx,%eax
  }
  return -1;
}
80104340:	5a                   	pop    %edx
80104341:	5b                   	pop    %ebx
80104342:	5d                   	pop    %ebp
80104343:	c3                   	ret    
    return -1;
80104344:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104349:	5a                   	pop    %edx
8010434a:	5b                   	pop    %ebx
8010434b:	5d                   	pop    %ebp
8010434c:	c3                   	ret    
8010434d:	8d 76 00             	lea    0x0(%esi),%esi

80104350 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104350:	55                   	push   %ebp
80104351:	89 e5                	mov    %esp,%ebp
80104353:	56                   	push   %esi
80104354:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104355:	e8 06 f0 ff ff       	call   80103360 <myproc>
8010435a:	8b 40 18             	mov    0x18(%eax),%eax
8010435d:	8b 40 44             	mov    0x44(%eax),%eax
80104360:	8b 55 08             	mov    0x8(%ebp),%edx
80104363:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
80104366:	8d 73 04             	lea    0x4(%ebx),%esi
  struct proc *curproc = myproc();
80104369:	e8 f2 ef ff ff       	call   80103360 <myproc>
  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010436e:	8b 00                	mov    (%eax),%eax
80104370:	39 c6                	cmp    %eax,%esi
80104372:	73 18                	jae    8010438c <argint+0x3c>
80104374:	8d 53 08             	lea    0x8(%ebx),%edx
80104377:	39 d0                	cmp    %edx,%eax
80104379:	72 11                	jb     8010438c <argint+0x3c>
  *ip = *(int*)(addr);
8010437b:	8b 53 04             	mov    0x4(%ebx),%edx
8010437e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104381:	89 10                	mov    %edx,(%eax)
  return 0;
80104383:	31 c0                	xor    %eax,%eax
}
80104385:	5b                   	pop    %ebx
80104386:	5e                   	pop    %esi
80104387:	5d                   	pop    %ebp
80104388:	c3                   	ret    
80104389:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
8010438c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104391:	eb f2                	jmp    80104385 <argint+0x35>
80104393:	90                   	nop

80104394 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104394:	55                   	push   %ebp
80104395:	89 e5                	mov    %esp,%ebp
80104397:	56                   	push   %esi
80104398:	53                   	push   %ebx
80104399:	83 ec 10             	sub    $0x10,%esp
8010439c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
8010439f:	e8 bc ef ff ff       	call   80103360 <myproc>
801043a4:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
801043a6:	83 ec 08             	sub    $0x8,%esp
801043a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801043ac:	50                   	push   %eax
801043ad:	ff 75 08             	pushl  0x8(%ebp)
801043b0:	e8 9b ff ff ff       	call   80104350 <argint>
801043b5:	83 c4 10             	add    $0x10,%esp
801043b8:	85 c0                	test   %eax,%eax
801043ba:	78 24                	js     801043e0 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801043bc:	85 db                	test   %ebx,%ebx
801043be:	78 20                	js     801043e0 <argptr+0x4c>
801043c0:	8b 16                	mov    (%esi),%edx
801043c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c5:	39 c2                	cmp    %eax,%edx
801043c7:	76 17                	jbe    801043e0 <argptr+0x4c>
801043c9:	01 c3                	add    %eax,%ebx
801043cb:	39 da                	cmp    %ebx,%edx
801043cd:	72 11                	jb     801043e0 <argptr+0x4c>
    return -1;
  *pp = (char*)i;
801043cf:	8b 55 0c             	mov    0xc(%ebp),%edx
801043d2:	89 02                	mov    %eax,(%edx)
  return 0;
801043d4:	31 c0                	xor    %eax,%eax
}
801043d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801043d9:	5b                   	pop    %ebx
801043da:	5e                   	pop    %esi
801043db:	5d                   	pop    %ebp
801043dc:	c3                   	ret    
801043dd:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
801043e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043e5:	eb ef                	jmp    801043d6 <argptr+0x42>
801043e7:	90                   	nop

801043e8 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801043e8:	55                   	push   %ebp
801043e9:	89 e5                	mov    %esp,%ebp
801043eb:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801043ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801043f1:	50                   	push   %eax
801043f2:	ff 75 08             	pushl  0x8(%ebp)
801043f5:	e8 56 ff ff ff       	call   80104350 <argint>
801043fa:	83 c4 10             	add    $0x10,%esp
801043fd:	85 c0                	test   %eax,%eax
801043ff:	78 13                	js     80104414 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80104401:	83 ec 08             	sub    $0x8,%esp
80104404:	ff 75 0c             	pushl  0xc(%ebp)
80104407:	ff 75 f4             	pushl  -0xc(%ebp)
8010440a:	e8 05 ff ff ff       	call   80104314 <fetchstr>
8010440f:	83 c4 10             	add    $0x10,%esp
}
80104412:	c9                   	leave  
80104413:	c3                   	ret    
    return -1;
80104414:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104419:	c9                   	leave  
8010441a:	c3                   	ret    
8010441b:	90                   	nop

8010441c <syscall>:
[SYS_getreadcount]   sys_getreadcount,
};

void
syscall(void)
{
8010441c:	55                   	push   %ebp
8010441d:	89 e5                	mov    %esp,%ebp
8010441f:	53                   	push   %ebx
80104420:	50                   	push   %eax
  int num;
  struct proc *curproc = myproc();
80104421:	e8 3a ef ff ff       	call   80103360 <myproc>
80104426:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104428:	8b 40 18             	mov    0x18(%eax),%eax
8010442b:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010442e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104431:	83 fa 15             	cmp    $0x15,%edx
80104434:	77 1a                	ja     80104450 <syscall+0x34>
80104436:	8b 14 85 80 6e 10 80 	mov    -0x7fef9180(,%eax,4),%edx
8010443d:	85 d2                	test   %edx,%edx
8010443f:	74 0f                	je     80104450 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104441:	ff d2                	call   *%edx
80104443:	8b 53 18             	mov    0x18(%ebx),%edx
80104446:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}	
80104449:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010444c:	c9                   	leave  
8010444d:	c3                   	ret    
8010444e:	66 90                	xchg   %ax,%ax
    cprintf("%d %s: unknown sys call %d\n",
80104450:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80104451:	8d 43 6c             	lea    0x6c(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80104454:	50                   	push   %eax
80104455:	ff 73 10             	pushl  0x10(%ebx)
80104458:	68 45 6e 10 80       	push   $0x80106e45
8010445d:	e8 be c1 ff ff       	call   80100620 <cprintf>
    curproc->tf->eax = -1;
80104462:	8b 43 18             	mov    0x18(%ebx),%eax
80104465:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010446c:	83 c4 10             	add    $0x10,%esp
}	
8010446f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104472:	c9                   	leave  
80104473:	c3                   	ret    

80104474 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104474:	55                   	push   %ebp
80104475:	89 e5                	mov    %esp,%ebp
80104477:	57                   	push   %edi
80104478:	56                   	push   %esi
80104479:	53                   	push   %ebx
8010447a:	83 ec 34             	sub    $0x34,%esp
8010447d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104480:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104483:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104486:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104489:	8d 7d da             	lea    -0x26(%ebp),%edi
8010448c:	57                   	push   %edi
8010448d:	50                   	push   %eax
8010448e:	e8 95 d8 ff ff       	call   80101d28 <nameiparent>
80104493:	83 c4 10             	add    $0x10,%esp
80104496:	85 c0                	test   %eax,%eax
80104498:	0f 84 22 01 00 00    	je     801045c0 <create+0x14c>
8010449e:	89 c3                	mov    %eax,%ebx
    return 0;
  ilock(dp);
801044a0:	83 ec 0c             	sub    $0xc,%esp
801044a3:	50                   	push   %eax
801044a4:	e8 b3 d0 ff ff       	call   8010155c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801044a9:	83 c4 0c             	add    $0xc,%esp
801044ac:	6a 00                	push   $0x0
801044ae:	57                   	push   %edi
801044af:	53                   	push   %ebx
801044b0:	e8 7b d5 ff ff       	call   80101a30 <dirlookup>
801044b5:	89 c6                	mov    %eax,%esi
801044b7:	83 c4 10             	add    $0x10,%esp
801044ba:	85 c0                	test   %eax,%eax
801044bc:	74 46                	je     80104504 <create+0x90>
    iunlockput(dp);
801044be:	83 ec 0c             	sub    $0xc,%esp
801044c1:	53                   	push   %ebx
801044c2:	e8 ed d2 ff ff       	call   801017b4 <iunlockput>
    ilock(ip);
801044c7:	89 34 24             	mov    %esi,(%esp)
801044ca:	e8 8d d0 ff ff       	call   8010155c <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801044cf:	83 c4 10             	add    $0x10,%esp
801044d2:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801044d7:	75 13                	jne    801044ec <create+0x78>
801044d9:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
801044de:	75 0c                	jne    801044ec <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801044e0:	89 f0                	mov    %esi,%eax
801044e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801044e5:	5b                   	pop    %ebx
801044e6:	5e                   	pop    %esi
801044e7:	5f                   	pop    %edi
801044e8:	5d                   	pop    %ebp
801044e9:	c3                   	ret    
801044ea:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
801044ec:	83 ec 0c             	sub    $0xc,%esp
801044ef:	56                   	push   %esi
801044f0:	e8 bf d2 ff ff       	call   801017b4 <iunlockput>
    return 0;
801044f5:	83 c4 10             	add    $0x10,%esp
801044f8:	31 f6                	xor    %esi,%esi
}
801044fa:	89 f0                	mov    %esi,%eax
801044fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801044ff:	5b                   	pop    %ebx
80104500:	5e                   	pop    %esi
80104501:	5f                   	pop    %edi
80104502:	5d                   	pop    %ebp
80104503:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104504:	83 ec 08             	sub    $0x8,%esp
80104507:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
8010450b:	50                   	push   %eax
8010450c:	ff 33                	pushl  (%ebx)
8010450e:	e8 f1 ce ff ff       	call   80101404 <ialloc>
80104513:	89 c6                	mov    %eax,%esi
80104515:	83 c4 10             	add    $0x10,%esp
80104518:	85 c0                	test   %eax,%eax
8010451a:	0f 84 b9 00 00 00    	je     801045d9 <create+0x165>
  ilock(ip);
80104520:	83 ec 0c             	sub    $0xc,%esp
80104523:	50                   	push   %eax
80104524:	e8 33 d0 ff ff       	call   8010155c <ilock>
  ip->major = major;
80104529:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010452c:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
80104530:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104533:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80104537:	66 c7 46 56 01 00    	movw   $0x1,0x56(%esi)
  iupdate(ip);
8010453d:	89 34 24             	mov    %esi,(%esp)
80104540:	e8 6f cf ff ff       	call   801014b4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104545:	83 c4 10             	add    $0x10,%esp
80104548:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010454d:	74 29                	je     80104578 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
8010454f:	50                   	push   %eax
80104550:	ff 76 04             	pushl  0x4(%esi)
80104553:	57                   	push   %edi
80104554:	53                   	push   %ebx
80104555:	e8 06 d7 ff ff       	call   80101c60 <dirlink>
8010455a:	83 c4 10             	add    $0x10,%esp
8010455d:	85 c0                	test   %eax,%eax
8010455f:	78 6b                	js     801045cc <create+0x158>
  iunlockput(dp);
80104561:	83 ec 0c             	sub    $0xc,%esp
80104564:	53                   	push   %ebx
80104565:	e8 4a d2 ff ff       	call   801017b4 <iunlockput>
  return ip;
8010456a:	83 c4 10             	add    $0x10,%esp
}
8010456d:	89 f0                	mov    %esi,%eax
8010456f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104572:	5b                   	pop    %ebx
80104573:	5e                   	pop    %esi
80104574:	5f                   	pop    %edi
80104575:	5d                   	pop    %ebp
80104576:	c3                   	ret    
80104577:	90                   	nop
    dp->nlink++;  // for ".."
80104578:	66 ff 43 56          	incw   0x56(%ebx)
    iupdate(dp);
8010457c:	83 ec 0c             	sub    $0xc,%esp
8010457f:	53                   	push   %ebx
80104580:	e8 2f cf ff ff       	call   801014b4 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104585:	83 c4 0c             	add    $0xc,%esp
80104588:	ff 76 04             	pushl  0x4(%esi)
8010458b:	68 f8 6e 10 80       	push   $0x80106ef8
80104590:	56                   	push   %esi
80104591:	e8 ca d6 ff ff       	call   80101c60 <dirlink>
80104596:	83 c4 10             	add    $0x10,%esp
80104599:	85 c0                	test   %eax,%eax
8010459b:	78 16                	js     801045b3 <create+0x13f>
8010459d:	52                   	push   %edx
8010459e:	ff 73 04             	pushl  0x4(%ebx)
801045a1:	68 f7 6e 10 80       	push   $0x80106ef7
801045a6:	56                   	push   %esi
801045a7:	e8 b4 d6 ff ff       	call   80101c60 <dirlink>
801045ac:	83 c4 10             	add    $0x10,%esp
801045af:	85 c0                	test   %eax,%eax
801045b1:	79 9c                	jns    8010454f <create+0xdb>
      panic("create dots");
801045b3:	83 ec 0c             	sub    $0xc,%esp
801045b6:	68 eb 6e 10 80       	push   $0x80106eeb
801045bb:	e8 80 bd ff ff       	call   80100340 <panic>
    return 0;
801045c0:	31 f6                	xor    %esi,%esi
}
801045c2:	89 f0                	mov    %esi,%eax
801045c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801045c7:	5b                   	pop    %ebx
801045c8:	5e                   	pop    %esi
801045c9:	5f                   	pop    %edi
801045ca:	5d                   	pop    %ebp
801045cb:	c3                   	ret    
    panic("create: dirlink");
801045cc:	83 ec 0c             	sub    $0xc,%esp
801045cf:	68 fa 6e 10 80       	push   $0x80106efa
801045d4:	e8 67 bd ff ff       	call   80100340 <panic>
    panic("create: ialloc");
801045d9:	83 ec 0c             	sub    $0xc,%esp
801045dc:	68 dc 6e 10 80       	push   $0x80106edc
801045e1:	e8 5a bd ff ff       	call   80100340 <panic>
801045e6:	66 90                	xchg   %ax,%ax

801045e8 <argfd.constprop.0>:
argfd(int n, int *pfd, struct file **pf)
801045e8:	55                   	push   %ebp
801045e9:	89 e5                	mov    %esp,%ebp
801045eb:	56                   	push   %esi
801045ec:	53                   	push   %ebx
801045ed:	83 ec 18             	sub    $0x18,%esp
801045f0:	89 c3                	mov    %eax,%ebx
801045f2:	89 d6                	mov    %edx,%esi
  if(argint(n, &fd) < 0)
801045f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801045f7:	50                   	push   %eax
801045f8:	6a 00                	push   $0x0
801045fa:	e8 51 fd ff ff       	call   80104350 <argint>
801045ff:	83 c4 10             	add    $0x10,%esp
80104602:	85 c0                	test   %eax,%eax
80104604:	78 2a                	js     80104630 <argfd.constprop.0+0x48>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104606:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010460a:	77 24                	ja     80104630 <argfd.constprop.0+0x48>
8010460c:	e8 4f ed ff ff       	call   80103360 <myproc>
80104611:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104614:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104618:	85 c0                	test   %eax,%eax
8010461a:	74 14                	je     80104630 <argfd.constprop.0+0x48>
  if(pfd)
8010461c:	85 db                	test   %ebx,%ebx
8010461e:	74 02                	je     80104622 <argfd.constprop.0+0x3a>
    *pfd = fd;
80104620:	89 13                	mov    %edx,(%ebx)
    *pf = f;
80104622:	89 06                	mov    %eax,(%esi)
  return 0;
80104624:	31 c0                	xor    %eax,%eax
}
80104626:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104629:	5b                   	pop    %ebx
8010462a:	5e                   	pop    %esi
8010462b:	5d                   	pop    %ebp
8010462c:	c3                   	ret    
8010462d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104635:	eb ef                	jmp    80104626 <argfd.constprop.0+0x3e>
80104637:	90                   	nop

80104638 <sys_dup>:
{
80104638:	55                   	push   %ebp
80104639:	89 e5                	mov    %esp,%ebp
8010463b:	56                   	push   %esi
8010463c:	53                   	push   %ebx
8010463d:	83 ec 10             	sub    $0x10,%esp
  if(argfd(0, 0, &f) < 0)
80104640:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104643:	31 c0                	xor    %eax,%eax
80104645:	e8 9e ff ff ff       	call   801045e8 <argfd.constprop.0>
8010464a:	85 c0                	test   %eax,%eax
8010464c:	78 18                	js     80104666 <sys_dup+0x2e>
  if((fd=fdalloc(f)) < 0)
8010464e:	8b 75 f4             	mov    -0xc(%ebp),%esi
  struct proc *curproc = myproc();
80104651:	e8 0a ed ff ff       	call   80103360 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80104656:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
80104658:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
8010465c:	85 d2                	test   %edx,%edx
8010465e:	74 14                	je     80104674 <sys_dup+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
80104660:	43                   	inc    %ebx
80104661:	83 fb 10             	cmp    $0x10,%ebx
80104664:	75 f2                	jne    80104658 <sys_dup+0x20>
    return -1;
80104666:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
8010466b:	89 d8                	mov    %ebx,%eax
8010466d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104670:	5b                   	pop    %ebx
80104671:	5e                   	pop    %esi
80104672:	5d                   	pop    %ebp
80104673:	c3                   	ret    
      curproc->ofile[fd] = f;
80104674:	89 74 98 28          	mov    %esi,0x28(%eax,%ebx,4)
  filedup(f);
80104678:	83 ec 0c             	sub    $0xc,%esp
8010467b:	ff 75 f4             	pushl  -0xc(%ebp)
8010467e:	e8 d5 c6 ff ff       	call   80100d58 <filedup>
  return fd;
80104683:	83 c4 10             	add    $0x10,%esp
}
80104686:	89 d8                	mov    %ebx,%eax
80104688:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010468b:	5b                   	pop    %ebx
8010468c:	5e                   	pop    %esi
8010468d:	5d                   	pop    %ebp
8010468e:	c3                   	ret    
8010468f:	90                   	nop

80104690 <sys_read>:
{
80104690:	55                   	push   %ebp
80104691:	89 e5                	mov    %esp,%ebp
80104693:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104696:	8d 55 ec             	lea    -0x14(%ebp),%edx
80104699:	31 c0                	xor    %eax,%eax
8010469b:	e8 48 ff ff ff       	call   801045e8 <argfd.constprop.0>
801046a0:	85 c0                	test   %eax,%eax
801046a2:	78 48                	js     801046ec <sys_read+0x5c>
801046a4:	83 ec 08             	sub    $0x8,%esp
801046a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801046aa:	50                   	push   %eax
801046ab:	6a 02                	push   $0x2
801046ad:	e8 9e fc ff ff       	call   80104350 <argint>
801046b2:	83 c4 10             	add    $0x10,%esp
801046b5:	85 c0                	test   %eax,%eax
801046b7:	78 33                	js     801046ec <sys_read+0x5c>
801046b9:	52                   	push   %edx
801046ba:	ff 75 f0             	pushl  -0x10(%ebp)
801046bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801046c0:	50                   	push   %eax
801046c1:	6a 01                	push   $0x1
801046c3:	e8 cc fc ff ff       	call   80104394 <argptr>
801046c8:	83 c4 10             	add    $0x10,%esp
801046cb:	85 c0                	test   %eax,%eax
801046cd:	78 1d                	js     801046ec <sys_read+0x5c>
  readcount++;
801046cf:	ff 05 80 af 10 80    	incl   0x8010af80
  return fileread(f, p, n);
801046d5:	50                   	push   %eax
801046d6:	ff 75 f0             	pushl  -0x10(%ebp)
801046d9:	ff 75 f4             	pushl  -0xc(%ebp)
801046dc:	ff 75 ec             	pushl  -0x14(%ebp)
801046df:	e8 bc c7 ff ff       	call   80100ea0 <fileread>
801046e4:	83 c4 10             	add    $0x10,%esp
}
801046e7:	c9                   	leave  
801046e8:	c3                   	ret    
801046e9:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
801046ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801046f1:	c9                   	leave  
801046f2:	c3                   	ret    
801046f3:	90                   	nop

801046f4 <sys_write>:
{
801046f4:	55                   	push   %ebp
801046f5:	89 e5                	mov    %esp,%ebp
801046f7:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801046fa:	8d 55 ec             	lea    -0x14(%ebp),%edx
801046fd:	31 c0                	xor    %eax,%eax
801046ff:	e8 e4 fe ff ff       	call   801045e8 <argfd.constprop.0>
80104704:	85 c0                	test   %eax,%eax
80104706:	78 40                	js     80104748 <sys_write+0x54>
80104708:	83 ec 08             	sub    $0x8,%esp
8010470b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010470e:	50                   	push   %eax
8010470f:	6a 02                	push   $0x2
80104711:	e8 3a fc ff ff       	call   80104350 <argint>
80104716:	83 c4 10             	add    $0x10,%esp
80104719:	85 c0                	test   %eax,%eax
8010471b:	78 2b                	js     80104748 <sys_write+0x54>
8010471d:	52                   	push   %edx
8010471e:	ff 75 f0             	pushl  -0x10(%ebp)
80104721:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104724:	50                   	push   %eax
80104725:	6a 01                	push   $0x1
80104727:	e8 68 fc ff ff       	call   80104394 <argptr>
8010472c:	83 c4 10             	add    $0x10,%esp
8010472f:	85 c0                	test   %eax,%eax
80104731:	78 15                	js     80104748 <sys_write+0x54>
  return filewrite(f, p, n);
80104733:	50                   	push   %eax
80104734:	ff 75 f0             	pushl  -0x10(%ebp)
80104737:	ff 75 f4             	pushl  -0xc(%ebp)
8010473a:	ff 75 ec             	pushl  -0x14(%ebp)
8010473d:	e8 ea c7 ff ff       	call   80100f2c <filewrite>
80104742:	83 c4 10             	add    $0x10,%esp
}
80104745:	c9                   	leave  
80104746:	c3                   	ret    
80104747:	90                   	nop
    return -1;
80104748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010474d:	c9                   	leave  
8010474e:	c3                   	ret    
8010474f:	90                   	nop

80104750 <sys_close>:
{
80104750:	55                   	push   %ebp
80104751:	89 e5                	mov    %esp,%ebp
80104753:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104756:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104759:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010475c:	e8 87 fe ff ff       	call   801045e8 <argfd.constprop.0>
80104761:	85 c0                	test   %eax,%eax
80104763:	78 23                	js     80104788 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
80104765:	e8 f6 eb ff ff       	call   80103360 <myproc>
8010476a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010476d:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104774:	00 
  fileclose(f);
80104775:	83 ec 0c             	sub    $0xc,%esp
80104778:	ff 75 f4             	pushl  -0xc(%ebp)
8010477b:	e8 1c c6 ff ff       	call   80100d9c <fileclose>
  return 0;
80104780:	83 c4 10             	add    $0x10,%esp
80104783:	31 c0                	xor    %eax,%eax
}
80104785:	c9                   	leave  
80104786:	c3                   	ret    
80104787:	90                   	nop
    return -1;
80104788:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010478d:	c9                   	leave  
8010478e:	c3                   	ret    
8010478f:	90                   	nop

80104790 <sys_fstat>:
{
80104790:	55                   	push   %ebp
80104791:	89 e5                	mov    %esp,%ebp
80104793:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104796:	8d 55 f0             	lea    -0x10(%ebp),%edx
80104799:	31 c0                	xor    %eax,%eax
8010479b:	e8 48 fe ff ff       	call   801045e8 <argfd.constprop.0>
801047a0:	85 c0                	test   %eax,%eax
801047a2:	78 28                	js     801047cc <sys_fstat+0x3c>
801047a4:	50                   	push   %eax
801047a5:	6a 14                	push   $0x14
801047a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801047aa:	50                   	push   %eax
801047ab:	6a 01                	push   $0x1
801047ad:	e8 e2 fb ff ff       	call   80104394 <argptr>
801047b2:	83 c4 10             	add    $0x10,%esp
801047b5:	85 c0                	test   %eax,%eax
801047b7:	78 13                	js     801047cc <sys_fstat+0x3c>
  return filestat(f, st);
801047b9:	83 ec 08             	sub    $0x8,%esp
801047bc:	ff 75 f4             	pushl  -0xc(%ebp)
801047bf:	ff 75 f0             	pushl  -0x10(%ebp)
801047c2:	e8 95 c6 ff ff       	call   80100e5c <filestat>
801047c7:	83 c4 10             	add    $0x10,%esp
}
801047ca:	c9                   	leave  
801047cb:	c3                   	ret    
    return -1;
801047cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801047d1:	c9                   	leave  
801047d2:	c3                   	ret    
801047d3:	90                   	nop

801047d4 <sys_link>:
{
801047d4:	55                   	push   %ebp
801047d5:	89 e5                	mov    %esp,%ebp
801047d7:	57                   	push   %edi
801047d8:	56                   	push   %esi
801047d9:	53                   	push   %ebx
801047da:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801047dd:	8d 45 d4             	lea    -0x2c(%ebp),%eax
801047e0:	50                   	push   %eax
801047e1:	6a 00                	push   $0x0
801047e3:	e8 00 fc ff ff       	call   801043e8 <argstr>
801047e8:	83 c4 10             	add    $0x10,%esp
801047eb:	85 c0                	test   %eax,%eax
801047ed:	0f 88 f2 00 00 00    	js     801048e5 <sys_link+0x111>
801047f3:	83 ec 08             	sub    $0x8,%esp
801047f6:	8d 45 d0             	lea    -0x30(%ebp),%eax
801047f9:	50                   	push   %eax
801047fa:	6a 01                	push   $0x1
801047fc:	e8 e7 fb ff ff       	call   801043e8 <argstr>
80104801:	83 c4 10             	add    $0x10,%esp
80104804:	85 c0                	test   %eax,%eax
80104806:	0f 88 d9 00 00 00    	js     801048e5 <sys_link+0x111>
  begin_op();
8010480c:	e8 2b e0 ff ff       	call   8010283c <begin_op>
  if((ip = namei(old)) == 0){
80104811:	83 ec 0c             	sub    $0xc,%esp
80104814:	ff 75 d4             	pushl  -0x2c(%ebp)
80104817:	e8 f4 d4 ff ff       	call   80101d10 <namei>
8010481c:	89 c3                	mov    %eax,%ebx
8010481e:	83 c4 10             	add    $0x10,%esp
80104821:	85 c0                	test   %eax,%eax
80104823:	0f 84 db 00 00 00    	je     80104904 <sys_link+0x130>
  ilock(ip);
80104829:	83 ec 0c             	sub    $0xc,%esp
8010482c:	50                   	push   %eax
8010482d:	e8 2a cd ff ff       	call   8010155c <ilock>
  if(ip->type == T_DIR){
80104832:	83 c4 10             	add    $0x10,%esp
80104835:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010483a:	0f 84 ac 00 00 00    	je     801048ec <sys_link+0x118>
  ip->nlink++;
80104840:	66 ff 43 56          	incw   0x56(%ebx)
  iupdate(ip);
80104844:	83 ec 0c             	sub    $0xc,%esp
80104847:	53                   	push   %ebx
80104848:	e8 67 cc ff ff       	call   801014b4 <iupdate>
  iunlock(ip);
8010484d:	89 1c 24             	mov    %ebx,(%esp)
80104850:	e8 cf cd ff ff       	call   80101624 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104855:	5a                   	pop    %edx
80104856:	59                   	pop    %ecx
80104857:	8d 7d da             	lea    -0x26(%ebp),%edi
8010485a:	57                   	push   %edi
8010485b:	ff 75 d0             	pushl  -0x30(%ebp)
8010485e:	e8 c5 d4 ff ff       	call   80101d28 <nameiparent>
80104863:	89 c6                	mov    %eax,%esi
80104865:	83 c4 10             	add    $0x10,%esp
80104868:	85 c0                	test   %eax,%eax
8010486a:	74 54                	je     801048c0 <sys_link+0xec>
  ilock(dp);
8010486c:	83 ec 0c             	sub    $0xc,%esp
8010486f:	50                   	push   %eax
80104870:	e8 e7 cc ff ff       	call   8010155c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104875:	83 c4 10             	add    $0x10,%esp
80104878:	8b 03                	mov    (%ebx),%eax
8010487a:	39 06                	cmp    %eax,(%esi)
8010487c:	75 36                	jne    801048b4 <sys_link+0xe0>
8010487e:	50                   	push   %eax
8010487f:	ff 73 04             	pushl  0x4(%ebx)
80104882:	57                   	push   %edi
80104883:	56                   	push   %esi
80104884:	e8 d7 d3 ff ff       	call   80101c60 <dirlink>
80104889:	83 c4 10             	add    $0x10,%esp
8010488c:	85 c0                	test   %eax,%eax
8010488e:	78 24                	js     801048b4 <sys_link+0xe0>
  iunlockput(dp);
80104890:	83 ec 0c             	sub    $0xc,%esp
80104893:	56                   	push   %esi
80104894:	e8 1b cf ff ff       	call   801017b4 <iunlockput>
  iput(ip);
80104899:	89 1c 24             	mov    %ebx,(%esp)
8010489c:	e8 c7 cd ff ff       	call   80101668 <iput>
  end_op();
801048a1:	e8 fe df ff ff       	call   801028a4 <end_op>
  return 0;
801048a6:	83 c4 10             	add    $0x10,%esp
801048a9:	31 c0                	xor    %eax,%eax
}
801048ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048ae:	5b                   	pop    %ebx
801048af:	5e                   	pop    %esi
801048b0:	5f                   	pop    %edi
801048b1:	5d                   	pop    %ebp
801048b2:	c3                   	ret    
801048b3:	90                   	nop
    iunlockput(dp);
801048b4:	83 ec 0c             	sub    $0xc,%esp
801048b7:	56                   	push   %esi
801048b8:	e8 f7 ce ff ff       	call   801017b4 <iunlockput>
    goto bad;
801048bd:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801048c0:	83 ec 0c             	sub    $0xc,%esp
801048c3:	53                   	push   %ebx
801048c4:	e8 93 cc ff ff       	call   8010155c <ilock>
  ip->nlink--;
801048c9:	66 ff 4b 56          	decw   0x56(%ebx)
  iupdate(ip);
801048cd:	89 1c 24             	mov    %ebx,(%esp)
801048d0:	e8 df cb ff ff       	call   801014b4 <iupdate>
  iunlockput(ip);
801048d5:	89 1c 24             	mov    %ebx,(%esp)
801048d8:	e8 d7 ce ff ff       	call   801017b4 <iunlockput>
  end_op();
801048dd:	e8 c2 df ff ff       	call   801028a4 <end_op>
  return -1;
801048e2:	83 c4 10             	add    $0x10,%esp
801048e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048ea:	eb bf                	jmp    801048ab <sys_link+0xd7>
    iunlockput(ip);
801048ec:	83 ec 0c             	sub    $0xc,%esp
801048ef:	53                   	push   %ebx
801048f0:	e8 bf ce ff ff       	call   801017b4 <iunlockput>
    end_op();
801048f5:	e8 aa df ff ff       	call   801028a4 <end_op>
    return -1;
801048fa:	83 c4 10             	add    $0x10,%esp
801048fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104902:	eb a7                	jmp    801048ab <sys_link+0xd7>
    end_op();
80104904:	e8 9b df ff ff       	call   801028a4 <end_op>
    return -1;
80104909:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010490e:	eb 9b                	jmp    801048ab <sys_link+0xd7>

80104910 <sys_unlink>:
{
80104910:	55                   	push   %ebp
80104911:	89 e5                	mov    %esp,%ebp
80104913:	57                   	push   %edi
80104914:	56                   	push   %esi
80104915:	53                   	push   %ebx
80104916:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
80104919:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010491c:	50                   	push   %eax
8010491d:	6a 00                	push   $0x0
8010491f:	e8 c4 fa ff ff       	call   801043e8 <argstr>
80104924:	83 c4 10             	add    $0x10,%esp
80104927:	85 c0                	test   %eax,%eax
80104929:	0f 88 69 01 00 00    	js     80104a98 <sys_unlink+0x188>
  begin_op();
8010492f:	e8 08 df ff ff       	call   8010283c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104934:	83 ec 08             	sub    $0x8,%esp
80104937:	8d 5d ca             	lea    -0x36(%ebp),%ebx
8010493a:	53                   	push   %ebx
8010493b:	ff 75 c0             	pushl  -0x40(%ebp)
8010493e:	e8 e5 d3 ff ff       	call   80101d28 <nameiparent>
80104943:	89 c6                	mov    %eax,%esi
80104945:	83 c4 10             	add    $0x10,%esp
80104948:	85 c0                	test   %eax,%eax
8010494a:	0f 84 52 01 00 00    	je     80104aa2 <sys_unlink+0x192>
  ilock(dp);
80104950:	83 ec 0c             	sub    $0xc,%esp
80104953:	50                   	push   %eax
80104954:	e8 03 cc ff ff       	call   8010155c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104959:	59                   	pop    %ecx
8010495a:	5f                   	pop    %edi
8010495b:	68 f8 6e 10 80       	push   $0x80106ef8
80104960:	53                   	push   %ebx
80104961:	e8 b2 d0 ff ff       	call   80101a18 <namecmp>
80104966:	83 c4 10             	add    $0x10,%esp
80104969:	85 c0                	test   %eax,%eax
8010496b:	0f 84 f7 00 00 00    	je     80104a68 <sys_unlink+0x158>
80104971:	83 ec 08             	sub    $0x8,%esp
80104974:	68 f7 6e 10 80       	push   $0x80106ef7
80104979:	53                   	push   %ebx
8010497a:	e8 99 d0 ff ff       	call   80101a18 <namecmp>
8010497f:	83 c4 10             	add    $0x10,%esp
80104982:	85 c0                	test   %eax,%eax
80104984:	0f 84 de 00 00 00    	je     80104a68 <sys_unlink+0x158>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010498a:	52                   	push   %edx
8010498b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010498e:	50                   	push   %eax
8010498f:	53                   	push   %ebx
80104990:	56                   	push   %esi
80104991:	e8 9a d0 ff ff       	call   80101a30 <dirlookup>
80104996:	89 c3                	mov    %eax,%ebx
80104998:	83 c4 10             	add    $0x10,%esp
8010499b:	85 c0                	test   %eax,%eax
8010499d:	0f 84 c5 00 00 00    	je     80104a68 <sys_unlink+0x158>
  ilock(ip);
801049a3:	83 ec 0c             	sub    $0xc,%esp
801049a6:	50                   	push   %eax
801049a7:	e8 b0 cb ff ff       	call   8010155c <ilock>
  if(ip->nlink < 1)
801049ac:	83 c4 10             	add    $0x10,%esp
801049af:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801049b4:	0f 8e 11 01 00 00    	jle    80104acb <sys_unlink+0x1bb>
  if(ip->type == T_DIR && !isdirempty(ip)){
801049ba:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801049bf:	74 63                	je     80104a24 <sys_unlink+0x114>
801049c1:	8d 7d d8             	lea    -0x28(%ebp),%edi
  memset(&de, 0, sizeof(de));
801049c4:	50                   	push   %eax
801049c5:	6a 10                	push   $0x10
801049c7:	6a 00                	push   $0x0
801049c9:	57                   	push   %edi
801049ca:	e8 5d f7 ff ff       	call   8010412c <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801049cf:	6a 10                	push   $0x10
801049d1:	ff 75 c4             	pushl  -0x3c(%ebp)
801049d4:	57                   	push   %edi
801049d5:	56                   	push   %esi
801049d6:	e8 1d cf ff ff       	call   801018f8 <writei>
801049db:	83 c4 20             	add    $0x20,%esp
801049de:	83 f8 10             	cmp    $0x10,%eax
801049e1:	0f 85 d7 00 00 00    	jne    80104abe <sys_unlink+0x1ae>
  if(ip->type == T_DIR){
801049e7:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801049ec:	0f 84 8e 00 00 00    	je     80104a80 <sys_unlink+0x170>
  iunlockput(dp);
801049f2:	83 ec 0c             	sub    $0xc,%esp
801049f5:	56                   	push   %esi
801049f6:	e8 b9 cd ff ff       	call   801017b4 <iunlockput>
  ip->nlink--;
801049fb:	66 ff 4b 56          	decw   0x56(%ebx)
  iupdate(ip);
801049ff:	89 1c 24             	mov    %ebx,(%esp)
80104a02:	e8 ad ca ff ff       	call   801014b4 <iupdate>
  iunlockput(ip);
80104a07:	89 1c 24             	mov    %ebx,(%esp)
80104a0a:	e8 a5 cd ff ff       	call   801017b4 <iunlockput>
  end_op();
80104a0f:	e8 90 de ff ff       	call   801028a4 <end_op>
  return 0;
80104a14:	83 c4 10             	add    $0x10,%esp
80104a17:	31 c0                	xor    %eax,%eax
}
80104a19:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a1c:	5b                   	pop    %ebx
80104a1d:	5e                   	pop    %esi
80104a1e:	5f                   	pop    %edi
80104a1f:	5d                   	pop    %ebp
80104a20:	c3                   	ret    
80104a21:	8d 76 00             	lea    0x0(%esi),%esi
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104a24:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
80104a28:	76 97                	jbe    801049c1 <sys_unlink+0xb1>
80104a2a:	ba 20 00 00 00       	mov    $0x20,%edx
80104a2f:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104a32:	eb 08                	jmp    80104a3c <sys_unlink+0x12c>
80104a34:	83 c2 10             	add    $0x10,%edx
80104a37:	39 53 58             	cmp    %edx,0x58(%ebx)
80104a3a:	76 88                	jbe    801049c4 <sys_unlink+0xb4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104a3c:	6a 10                	push   $0x10
80104a3e:	52                   	push   %edx
80104a3f:	89 55 b4             	mov    %edx,-0x4c(%ebp)
80104a42:	57                   	push   %edi
80104a43:	53                   	push   %ebx
80104a44:	e8 b7 cd ff ff       	call   80101800 <readi>
80104a49:	83 c4 10             	add    $0x10,%esp
80104a4c:	83 f8 10             	cmp    $0x10,%eax
80104a4f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
80104a52:	75 5d                	jne    80104ab1 <sys_unlink+0x1a1>
    if(de.inum != 0)
80104a54:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80104a59:	74 d9                	je     80104a34 <sys_unlink+0x124>
    iunlockput(ip);
80104a5b:	83 ec 0c             	sub    $0xc,%esp
80104a5e:	53                   	push   %ebx
80104a5f:	e8 50 cd ff ff       	call   801017b4 <iunlockput>
    goto bad;
80104a64:	83 c4 10             	add    $0x10,%esp
80104a67:	90                   	nop
  iunlockput(dp);
80104a68:	83 ec 0c             	sub    $0xc,%esp
80104a6b:	56                   	push   %esi
80104a6c:	e8 43 cd ff ff       	call   801017b4 <iunlockput>
  end_op();
80104a71:	e8 2e de ff ff       	call   801028a4 <end_op>
  return -1;
80104a76:	83 c4 10             	add    $0x10,%esp
80104a79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a7e:	eb 99                	jmp    80104a19 <sys_unlink+0x109>
    dp->nlink--;
80104a80:	66 ff 4e 56          	decw   0x56(%esi)
    iupdate(dp);
80104a84:	83 ec 0c             	sub    $0xc,%esp
80104a87:	56                   	push   %esi
80104a88:	e8 27 ca ff ff       	call   801014b4 <iupdate>
80104a8d:	83 c4 10             	add    $0x10,%esp
80104a90:	e9 5d ff ff ff       	jmp    801049f2 <sys_unlink+0xe2>
80104a95:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104a98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a9d:	e9 77 ff ff ff       	jmp    80104a19 <sys_unlink+0x109>
    end_op();
80104aa2:	e8 fd dd ff ff       	call   801028a4 <end_op>
    return -1;
80104aa7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aac:	e9 68 ff ff ff       	jmp    80104a19 <sys_unlink+0x109>
      panic("isdirempty: readi");
80104ab1:	83 ec 0c             	sub    $0xc,%esp
80104ab4:	68 1c 6f 10 80       	push   $0x80106f1c
80104ab9:	e8 82 b8 ff ff       	call   80100340 <panic>
    panic("unlink: writei");
80104abe:	83 ec 0c             	sub    $0xc,%esp
80104ac1:	68 2e 6f 10 80       	push   $0x80106f2e
80104ac6:	e8 75 b8 ff ff       	call   80100340 <panic>
    panic("unlink: nlink < 1");
80104acb:	83 ec 0c             	sub    $0xc,%esp
80104ace:	68 0a 6f 10 80       	push   $0x80106f0a
80104ad3:	e8 68 b8 ff ff       	call   80100340 <panic>

80104ad8 <sys_open>:

int
sys_open(void)
{
80104ad8:	55                   	push   %ebp
80104ad9:	89 e5                	mov    %esp,%ebp
80104adb:	56                   	push   %esi
80104adc:	53                   	push   %ebx
80104add:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104ae0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ae3:	50                   	push   %eax
80104ae4:	6a 00                	push   $0x0
80104ae6:	e8 fd f8 ff ff       	call   801043e8 <argstr>
80104aeb:	83 c4 10             	add    $0x10,%esp
80104aee:	85 c0                	test   %eax,%eax
80104af0:	0f 88 8d 00 00 00    	js     80104b83 <sys_open+0xab>
80104af6:	83 ec 08             	sub    $0x8,%esp
80104af9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104afc:	50                   	push   %eax
80104afd:	6a 01                	push   $0x1
80104aff:	e8 4c f8 ff ff       	call   80104350 <argint>
80104b04:	83 c4 10             	add    $0x10,%esp
80104b07:	85 c0                	test   %eax,%eax
80104b09:	78 78                	js     80104b83 <sys_open+0xab>
    return -1;

  begin_op();
80104b0b:	e8 2c dd ff ff       	call   8010283c <begin_op>

  if(omode & O_CREATE){
80104b10:	f6 45 f5 02          	testb  $0x2,-0xb(%ebp)
80104b14:	75 76                	jne    80104b8c <sys_open+0xb4>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
80104b16:	83 ec 0c             	sub    $0xc,%esp
80104b19:	ff 75 f0             	pushl  -0x10(%ebp)
80104b1c:	e8 ef d1 ff ff       	call   80101d10 <namei>
80104b21:	89 c3                	mov    %eax,%ebx
80104b23:	83 c4 10             	add    $0x10,%esp
80104b26:	85 c0                	test   %eax,%eax
80104b28:	74 7f                	je     80104ba9 <sys_open+0xd1>
      end_op();
      return -1;
    }
    ilock(ip);
80104b2a:	83 ec 0c             	sub    $0xc,%esp
80104b2d:	50                   	push   %eax
80104b2e:	e8 29 ca ff ff       	call   8010155c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104b33:	83 c4 10             	add    $0x10,%esp
80104b36:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104b3b:	0f 84 bf 00 00 00    	je     80104c00 <sys_open+0x128>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104b41:	e8 b2 c1 ff ff       	call   80100cf8 <filealloc>
80104b46:	89 c6                	mov    %eax,%esi
80104b48:	85 c0                	test   %eax,%eax
80104b4a:	74 26                	je     80104b72 <sys_open+0x9a>
  struct proc *curproc = myproc();
80104b4c:	e8 0f e8 ff ff       	call   80103360 <myproc>
80104b51:	89 c2                	mov    %eax,%edx
  for(fd = 0; fd < NOFILE; fd++){
80104b53:	31 c0                	xor    %eax,%eax
80104b55:	8d 76 00             	lea    0x0(%esi),%esi
    if(curproc->ofile[fd] == 0){
80104b58:	8b 4c 82 28          	mov    0x28(%edx,%eax,4),%ecx
80104b5c:	85 c9                	test   %ecx,%ecx
80104b5e:	74 58                	je     80104bb8 <sys_open+0xe0>
  for(fd = 0; fd < NOFILE; fd++){
80104b60:	40                   	inc    %eax
80104b61:	83 f8 10             	cmp    $0x10,%eax
80104b64:	75 f2                	jne    80104b58 <sys_open+0x80>
    if(f)
      fileclose(f);
80104b66:	83 ec 0c             	sub    $0xc,%esp
80104b69:	56                   	push   %esi
80104b6a:	e8 2d c2 ff ff       	call   80100d9c <fileclose>
80104b6f:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104b72:	83 ec 0c             	sub    $0xc,%esp
80104b75:	53                   	push   %ebx
80104b76:	e8 39 cc ff ff       	call   801017b4 <iunlockput>
    end_op();
80104b7b:	e8 24 dd ff ff       	call   801028a4 <end_op>
    return -1;
80104b80:	83 c4 10             	add    $0x10,%esp
80104b83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b88:	eb 6d                	jmp    80104bf7 <sys_open+0x11f>
80104b8a:	66 90                	xchg   %ax,%ax
    ip = create(path, T_FILE, 0, 0);
80104b8c:	83 ec 0c             	sub    $0xc,%esp
80104b8f:	6a 00                	push   $0x0
80104b91:	31 c9                	xor    %ecx,%ecx
80104b93:	ba 02 00 00 00       	mov    $0x2,%edx
80104b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b9b:	e8 d4 f8 ff ff       	call   80104474 <create>
80104ba0:	89 c3                	mov    %eax,%ebx
    if(ip == 0){
80104ba2:	83 c4 10             	add    $0x10,%esp
80104ba5:	85 c0                	test   %eax,%eax
80104ba7:	75 98                	jne    80104b41 <sys_open+0x69>
      end_op();
80104ba9:	e8 f6 dc ff ff       	call   801028a4 <end_op>
      return -1;
80104bae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bb3:	eb 42                	jmp    80104bf7 <sys_open+0x11f>
80104bb5:	8d 76 00             	lea    0x0(%esi),%esi
      curproc->ofile[fd] = f;
80104bb8:	89 74 82 28          	mov    %esi,0x28(%edx,%eax,4)
80104bbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  }
  iunlock(ip);
80104bbf:	83 ec 0c             	sub    $0xc,%esp
80104bc2:	53                   	push   %ebx
80104bc3:	e8 5c ca ff ff       	call   80101624 <iunlock>
  end_op();
80104bc8:	e8 d7 dc ff ff       	call   801028a4 <end_op>

  f->type = FD_INODE;
80104bcd:	c7 06 02 00 00 00    	movl   $0x2,(%esi)
  f->ip = ip;
80104bd3:	89 5e 10             	mov    %ebx,0x10(%esi)
  f->off = 0;
80104bd6:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)
  f->readable = !(omode & O_WRONLY);
80104bdd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104be0:	89 ca                	mov    %ecx,%edx
80104be2:	f7 d2                	not    %edx
80104be4:	83 e2 01             	and    $0x1,%edx
80104be7:	88 56 08             	mov    %dl,0x8(%esi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104bea:	83 c4 10             	add    $0x10,%esp
80104bed:	83 e1 03             	and    $0x3,%ecx
80104bf0:	0f 95 46 09          	setne  0x9(%esi)
  return fd;
80104bf4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80104bf7:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104bfa:	5b                   	pop    %ebx
80104bfb:	5e                   	pop    %esi
80104bfc:	5d                   	pop    %ebp
80104bfd:	c3                   	ret    
80104bfe:	66 90                	xchg   %ax,%ax
    if(ip->type == T_DIR && omode != O_RDONLY){
80104c00:	8b 75 f4             	mov    -0xc(%ebp),%esi
80104c03:	85 f6                	test   %esi,%esi
80104c05:	0f 84 36 ff ff ff    	je     80104b41 <sys_open+0x69>
80104c0b:	e9 62 ff ff ff       	jmp    80104b72 <sys_open+0x9a>

80104c10 <sys_mkdir>:

int
sys_mkdir(void)
{
80104c10:	55                   	push   %ebp
80104c11:	89 e5                	mov    %esp,%ebp
80104c13:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104c16:	e8 21 dc ff ff       	call   8010283c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104c1b:	83 ec 08             	sub    $0x8,%esp
80104c1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c21:	50                   	push   %eax
80104c22:	6a 00                	push   $0x0
80104c24:	e8 bf f7 ff ff       	call   801043e8 <argstr>
80104c29:	83 c4 10             	add    $0x10,%esp
80104c2c:	85 c0                	test   %eax,%eax
80104c2e:	78 30                	js     80104c60 <sys_mkdir+0x50>
80104c30:	83 ec 0c             	sub    $0xc,%esp
80104c33:	6a 00                	push   $0x0
80104c35:	31 c9                	xor    %ecx,%ecx
80104c37:	ba 01 00 00 00       	mov    $0x1,%edx
80104c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3f:	e8 30 f8 ff ff       	call   80104474 <create>
80104c44:	83 c4 10             	add    $0x10,%esp
80104c47:	85 c0                	test   %eax,%eax
80104c49:	74 15                	je     80104c60 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104c4b:	83 ec 0c             	sub    $0xc,%esp
80104c4e:	50                   	push   %eax
80104c4f:	e8 60 cb ff ff       	call   801017b4 <iunlockput>
  end_op();
80104c54:	e8 4b dc ff ff       	call   801028a4 <end_op>
  return 0;
80104c59:	83 c4 10             	add    $0x10,%esp
80104c5c:	31 c0                	xor    %eax,%eax
}
80104c5e:	c9                   	leave  
80104c5f:	c3                   	ret    
    end_op();
80104c60:	e8 3f dc ff ff       	call   801028a4 <end_op>
    return -1;
80104c65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c6a:	c9                   	leave  
80104c6b:	c3                   	ret    

80104c6c <sys_mknod>:

int
sys_mknod(void)
{
80104c6c:	55                   	push   %ebp
80104c6d:	89 e5                	mov    %esp,%ebp
80104c6f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104c72:	e8 c5 db ff ff       	call   8010283c <begin_op>
  if((argstr(0, &path)) < 0 ||
80104c77:	83 ec 08             	sub    $0x8,%esp
80104c7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104c7d:	50                   	push   %eax
80104c7e:	6a 00                	push   $0x0
80104c80:	e8 63 f7 ff ff       	call   801043e8 <argstr>
80104c85:	83 c4 10             	add    $0x10,%esp
80104c88:	85 c0                	test   %eax,%eax
80104c8a:	78 60                	js     80104cec <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80104c8c:	83 ec 08             	sub    $0x8,%esp
80104c8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c92:	50                   	push   %eax
80104c93:	6a 01                	push   $0x1
80104c95:	e8 b6 f6 ff ff       	call   80104350 <argint>
  if((argstr(0, &path)) < 0 ||
80104c9a:	83 c4 10             	add    $0x10,%esp
80104c9d:	85 c0                	test   %eax,%eax
80104c9f:	78 4b                	js     80104cec <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80104ca1:	83 ec 08             	sub    $0x8,%esp
80104ca4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ca7:	50                   	push   %eax
80104ca8:	6a 02                	push   $0x2
80104caa:	e8 a1 f6 ff ff       	call   80104350 <argint>
     argint(1, &major) < 0 ||
80104caf:	83 c4 10             	add    $0x10,%esp
80104cb2:	85 c0                	test   %eax,%eax
80104cb4:	78 36                	js     80104cec <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104cb6:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80104cba:	83 ec 0c             	sub    $0xc,%esp
80104cbd:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
80104cc1:	50                   	push   %eax
80104cc2:	ba 03 00 00 00       	mov    $0x3,%edx
80104cc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cca:	e8 a5 f7 ff ff       	call   80104474 <create>
     argint(2, &minor) < 0 ||
80104ccf:	83 c4 10             	add    $0x10,%esp
80104cd2:	85 c0                	test   %eax,%eax
80104cd4:	74 16                	je     80104cec <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104cd6:	83 ec 0c             	sub    $0xc,%esp
80104cd9:	50                   	push   %eax
80104cda:	e8 d5 ca ff ff       	call   801017b4 <iunlockput>
  end_op();
80104cdf:	e8 c0 db ff ff       	call   801028a4 <end_op>
  return 0;
80104ce4:	83 c4 10             	add    $0x10,%esp
80104ce7:	31 c0                	xor    %eax,%eax
}
80104ce9:	c9                   	leave  
80104cea:	c3                   	ret    
80104ceb:	90                   	nop
    end_op();
80104cec:	e8 b3 db ff ff       	call   801028a4 <end_op>
    return -1;
80104cf1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cf6:	c9                   	leave  
80104cf7:	c3                   	ret    

80104cf8 <sys_chdir>:

int
sys_chdir(void)
{
80104cf8:	55                   	push   %ebp
80104cf9:	89 e5                	mov    %esp,%ebp
80104cfb:	56                   	push   %esi
80104cfc:	53                   	push   %ebx
80104cfd:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104d00:	e8 5b e6 ff ff       	call   80103360 <myproc>
80104d05:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104d07:	e8 30 db ff ff       	call   8010283c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104d0c:	83 ec 08             	sub    $0x8,%esp
80104d0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d12:	50                   	push   %eax
80104d13:	6a 00                	push   $0x0
80104d15:	e8 ce f6 ff ff       	call   801043e8 <argstr>
80104d1a:	83 c4 10             	add    $0x10,%esp
80104d1d:	85 c0                	test   %eax,%eax
80104d1f:	78 67                	js     80104d88 <sys_chdir+0x90>
80104d21:	83 ec 0c             	sub    $0xc,%esp
80104d24:	ff 75 f4             	pushl  -0xc(%ebp)
80104d27:	e8 e4 cf ff ff       	call   80101d10 <namei>
80104d2c:	89 c3                	mov    %eax,%ebx
80104d2e:	83 c4 10             	add    $0x10,%esp
80104d31:	85 c0                	test   %eax,%eax
80104d33:	74 53                	je     80104d88 <sys_chdir+0x90>
    end_op();
    return -1;
  }
  ilock(ip);
80104d35:	83 ec 0c             	sub    $0xc,%esp
80104d38:	50                   	push   %eax
80104d39:	e8 1e c8 ff ff       	call   8010155c <ilock>
  if(ip->type != T_DIR){
80104d3e:	83 c4 10             	add    $0x10,%esp
80104d41:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104d46:	75 28                	jne    80104d70 <sys_chdir+0x78>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104d48:	83 ec 0c             	sub    $0xc,%esp
80104d4b:	53                   	push   %ebx
80104d4c:	e8 d3 c8 ff ff       	call   80101624 <iunlock>
  iput(curproc->cwd);
80104d51:	58                   	pop    %eax
80104d52:	ff 76 68             	pushl  0x68(%esi)
80104d55:	e8 0e c9 ff ff       	call   80101668 <iput>
  end_op();
80104d5a:	e8 45 db ff ff       	call   801028a4 <end_op>
  curproc->cwd = ip;
80104d5f:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104d62:	83 c4 10             	add    $0x10,%esp
80104d65:	31 c0                	xor    %eax,%eax
}
80104d67:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104d6a:	5b                   	pop    %ebx
80104d6b:	5e                   	pop    %esi
80104d6c:	5d                   	pop    %ebp
80104d6d:	c3                   	ret    
80104d6e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
80104d70:	83 ec 0c             	sub    $0xc,%esp
80104d73:	53                   	push   %ebx
80104d74:	e8 3b ca ff ff       	call   801017b4 <iunlockput>
    end_op();
80104d79:	e8 26 db ff ff       	call   801028a4 <end_op>
    return -1;
80104d7e:	83 c4 10             	add    $0x10,%esp
80104d81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d86:	eb df                	jmp    80104d67 <sys_chdir+0x6f>
    end_op();
80104d88:	e8 17 db ff ff       	call   801028a4 <end_op>
    return -1;
80104d8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d92:	eb d3                	jmp    80104d67 <sys_chdir+0x6f>

80104d94 <sys_exec>:

int
sys_exec(void)
{
80104d94:	55                   	push   %ebp
80104d95:	89 e5                	mov    %esp,%ebp
80104d97:	57                   	push   %edi
80104d98:	56                   	push   %esi
80104d99:	53                   	push   %ebx
80104d9a:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104da0:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
80104da6:	50                   	push   %eax
80104da7:	6a 00                	push   $0x0
80104da9:	e8 3a f6 ff ff       	call   801043e8 <argstr>
80104dae:	83 c4 10             	add    $0x10,%esp
80104db1:	85 c0                	test   %eax,%eax
80104db3:	78 79                	js     80104e2e <sys_exec+0x9a>
80104db5:	83 ec 08             	sub    $0x8,%esp
80104db8:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80104dbe:	50                   	push   %eax
80104dbf:	6a 01                	push   $0x1
80104dc1:	e8 8a f5 ff ff       	call   80104350 <argint>
80104dc6:	83 c4 10             	add    $0x10,%esp
80104dc9:	85 c0                	test   %eax,%eax
80104dcb:	78 61                	js     80104e2e <sys_exec+0x9a>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104dcd:	50                   	push   %eax
80104dce:	68 80 00 00 00       	push   $0x80
80104dd3:	6a 00                	push   $0x0
80104dd5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
80104ddb:	57                   	push   %edi
80104ddc:	e8 4b f3 ff ff       	call   8010412c <memset>
80104de1:	83 c4 10             	add    $0x10,%esp
80104de4:	31 db                	xor    %ebx,%ebx
  for(i=0;; i++){
80104de6:	31 f6                	xor    %esi,%esi
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104de8:	83 ec 08             	sub    $0x8,%esp
80104deb:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80104df1:	50                   	push   %eax
80104df2:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80104df8:	01 d8                	add    %ebx,%eax
80104dfa:	50                   	push   %eax
80104dfb:	e8 e4 f4 ff ff       	call   801042e4 <fetchint>
80104e00:	83 c4 10             	add    $0x10,%esp
80104e03:	85 c0                	test   %eax,%eax
80104e05:	78 27                	js     80104e2e <sys_exec+0x9a>
      return -1;
    if(uarg == 0){
80104e07:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80104e0d:	85 c0                	test   %eax,%eax
80104e0f:	74 2b                	je     80104e3c <sys_exec+0xa8>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104e11:	83 ec 08             	sub    $0x8,%esp
80104e14:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
80104e17:	52                   	push   %edx
80104e18:	50                   	push   %eax
80104e19:	e8 f6 f4 ff ff       	call   80104314 <fetchstr>
80104e1e:	83 c4 10             	add    $0x10,%esp
80104e21:	85 c0                	test   %eax,%eax
80104e23:	78 09                	js     80104e2e <sys_exec+0x9a>
  for(i=0;; i++){
80104e25:	46                   	inc    %esi
    if(i >= NELEM(argv))
80104e26:	83 c3 04             	add    $0x4,%ebx
80104e29:	83 fe 20             	cmp    $0x20,%esi
80104e2c:	75 ba                	jne    80104de8 <sys_exec+0x54>
    return -1;
80104e2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return -1;
  }
  return exec(path, argv);
}
80104e33:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104e36:	5b                   	pop    %ebx
80104e37:	5e                   	pop    %esi
80104e38:	5f                   	pop    %edi
80104e39:	5d                   	pop    %ebp
80104e3a:	c3                   	ret    
80104e3b:	90                   	nop
      argv[i] = 0;
80104e3c:	c7 84 b5 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%esi,4)
80104e43:	00 00 00 00 
  return exec(path, argv);
80104e47:	83 ec 08             	sub    $0x8,%esp
80104e4a:	57                   	push   %edi
80104e4b:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
80104e51:	e8 4e bb ff ff       	call   801009a4 <exec>
80104e56:	83 c4 10             	add    $0x10,%esp
}
80104e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104e5c:	5b                   	pop    %ebx
80104e5d:	5e                   	pop    %esi
80104e5e:	5f                   	pop    %edi
80104e5f:	5d                   	pop    %ebp
80104e60:	c3                   	ret    
80104e61:	8d 76 00             	lea    0x0(%esi),%esi

80104e64 <sys_pipe>:

int
sys_pipe(void)
{
80104e64:	55                   	push   %ebp
80104e65:	89 e5                	mov    %esp,%ebp
80104e67:	57                   	push   %edi
80104e68:	56                   	push   %esi
80104e69:	53                   	push   %ebx
80104e6a:	83 ec 20             	sub    $0x20,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104e6d:	6a 08                	push   $0x8
80104e6f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80104e72:	50                   	push   %eax
80104e73:	6a 00                	push   $0x0
80104e75:	e8 1a f5 ff ff       	call   80104394 <argptr>
80104e7a:	83 c4 10             	add    $0x10,%esp
80104e7d:	85 c0                	test   %eax,%eax
80104e7f:	78 48                	js     80104ec9 <sys_pipe+0x65>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104e81:	83 ec 08             	sub    $0x8,%esp
80104e84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104e87:	50                   	push   %eax
80104e88:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104e8b:	50                   	push   %eax
80104e8c:	e8 a3 df ff ff       	call   80102e34 <pipealloc>
80104e91:	83 c4 10             	add    $0x10,%esp
80104e94:	85 c0                	test   %eax,%eax
80104e96:	78 31                	js     80104ec9 <sys_pipe+0x65>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104e98:	8b 7d e0             	mov    -0x20(%ebp),%edi
  struct proc *curproc = myproc();
80104e9b:	e8 c0 e4 ff ff       	call   80103360 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80104ea0:	31 db                	xor    %ebx,%ebx
80104ea2:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80104ea4:	8b 74 98 28          	mov    0x28(%eax,%ebx,4),%esi
80104ea8:	85 f6                	test   %esi,%esi
80104eaa:	74 24                	je     80104ed0 <sys_pipe+0x6c>
  for(fd = 0; fd < NOFILE; fd++){
80104eac:	43                   	inc    %ebx
80104ead:	83 fb 10             	cmp    $0x10,%ebx
80104eb0:	75 f2                	jne    80104ea4 <sys_pipe+0x40>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
80104eb2:	83 ec 0c             	sub    $0xc,%esp
80104eb5:	ff 75 e0             	pushl  -0x20(%ebp)
80104eb8:	e8 df be ff ff       	call   80100d9c <fileclose>
    fileclose(wf);
80104ebd:	58                   	pop    %eax
80104ebe:	ff 75 e4             	pushl  -0x1c(%ebp)
80104ec1:	e8 d6 be ff ff       	call   80100d9c <fileclose>
    return -1;
80104ec6:	83 c4 10             	add    $0x10,%esp
80104ec9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ece:	eb 45                	jmp    80104f15 <sys_pipe+0xb1>
      curproc->ofile[fd] = f;
80104ed0:	8d 73 08             	lea    0x8(%ebx),%esi
80104ed3:	89 7c b0 08          	mov    %edi,0x8(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104ed7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
80104eda:	e8 81 e4 ff ff       	call   80103360 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80104edf:	31 d2                	xor    %edx,%edx
80104ee1:	8d 76 00             	lea    0x0(%esi),%esi
    if(curproc->ofile[fd] == 0){
80104ee4:	8b 4c 90 28          	mov    0x28(%eax,%edx,4),%ecx
80104ee8:	85 c9                	test   %ecx,%ecx
80104eea:	74 18                	je     80104f04 <sys_pipe+0xa0>
  for(fd = 0; fd < NOFILE; fd++){
80104eec:	42                   	inc    %edx
80104eed:	83 fa 10             	cmp    $0x10,%edx
80104ef0:	75 f2                	jne    80104ee4 <sys_pipe+0x80>
      myproc()->ofile[fd0] = 0;
80104ef2:	e8 69 e4 ff ff       	call   80103360 <myproc>
80104ef7:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
80104efe:	00 
80104eff:	eb b1                	jmp    80104eb2 <sys_pipe+0x4e>
80104f01:	8d 76 00             	lea    0x0(%esi),%esi
      curproc->ofile[fd] = f;
80104f04:	89 7c 90 28          	mov    %edi,0x28(%eax,%edx,4)
  }
  fd[0] = fd0;
80104f08:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104f0b:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80104f0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104f10:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80104f13:	31 c0                	xor    %eax,%eax
}
80104f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f18:	5b                   	pop    %ebx
80104f19:	5e                   	pop    %esi
80104f1a:	5f                   	pop    %edi
80104f1b:	5d                   	pop    %ebp
80104f1c:	c3                   	ret    
80104f1d:	8d 76 00             	lea    0x0(%esi),%esi

80104f20 <sys_getreadcount>:

int
sys_getreadcount(void)
{
  return readcount;
}
80104f20:	a1 80 af 10 80       	mov    0x8010af80,%eax
80104f25:	c3                   	ret    
80104f26:	66 90                	xchg   %ax,%ax

80104f28 <sys_fork>:
#include "proc.h"

int
sys_fork(void)
{
  return fork();
80104f28:	e9 ab e5 ff ff       	jmp    801034d8 <fork>
80104f2d:	8d 76 00             	lea    0x0(%esi),%esi

80104f30 <sys_exit>:
}

int
sys_exit(void)
{
80104f30:	55                   	push   %ebp
80104f31:	89 e5                	mov    %esp,%ebp
80104f33:	83 ec 08             	sub    $0x8,%esp
  exit();
80104f36:	e8 51 e8 ff ff       	call   8010378c <exit>
  return 0;  // not reached
}
80104f3b:	31 c0                	xor    %eax,%eax
80104f3d:	c9                   	leave  
80104f3e:	c3                   	ret    
80104f3f:	90                   	nop

80104f40 <sys_wait>:

int
sys_wait(void)
{
  return wait();
80104f40:	e9 67 ea ff ff       	jmp    801039ac <wait>
80104f45:	8d 76 00             	lea    0x0(%esi),%esi

80104f48 <sys_kill>:
}

int
sys_kill(void)
{
80104f48:	55                   	push   %ebp
80104f49:	89 e5                	mov    %esp,%ebp
80104f4b:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104f4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f51:	50                   	push   %eax
80104f52:	6a 00                	push   $0x0
80104f54:	e8 f7 f3 ff ff       	call   80104350 <argint>
80104f59:	83 c4 10             	add    $0x10,%esp
80104f5c:	85 c0                	test   %eax,%eax
80104f5e:	78 10                	js     80104f70 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104f60:	83 ec 0c             	sub    $0xc,%esp
80104f63:	ff 75 f4             	pushl  -0xc(%ebp)
80104f66:	e8 89 eb ff ff       	call   80103af4 <kill>
80104f6b:	83 c4 10             	add    $0x10,%esp
}
80104f6e:	c9                   	leave  
80104f6f:	c3                   	ret    
    return -1;
80104f70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f75:	c9                   	leave  
80104f76:	c3                   	ret    
80104f77:	90                   	nop

80104f78 <sys_getpid>:

int
sys_getpid(void)
{
80104f78:	55                   	push   %ebp
80104f79:	89 e5                	mov    %esp,%ebp
80104f7b:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104f7e:	e8 dd e3 ff ff       	call   80103360 <myproc>
80104f83:	8b 40 10             	mov    0x10(%eax),%eax
}
80104f86:	c9                   	leave  
80104f87:	c3                   	ret    

80104f88 <sys_sbrk>:

int
sys_sbrk(void)
{
80104f88:	55                   	push   %ebp
80104f89:	89 e5                	mov    %esp,%ebp
80104f8b:	53                   	push   %ebx
80104f8c:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104f8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f92:	50                   	push   %eax
80104f93:	6a 00                	push   $0x0
80104f95:	e8 b6 f3 ff ff       	call   80104350 <argint>
80104f9a:	83 c4 10             	add    $0x10,%esp
80104f9d:	85 c0                	test   %eax,%eax
80104f9f:	78 23                	js     80104fc4 <sys_sbrk+0x3c>
    return -1;
  addr = myproc()->sz;
80104fa1:	e8 ba e3 ff ff       	call   80103360 <myproc>
80104fa6:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104fa8:	83 ec 0c             	sub    $0xc,%esp
80104fab:	ff 75 f4             	pushl  -0xc(%ebp)
80104fae:	e8 b5 e4 ff ff       	call   80103468 <growproc>
80104fb3:	83 c4 10             	add    $0x10,%esp
80104fb6:	85 c0                	test   %eax,%eax
80104fb8:	78 0a                	js     80104fc4 <sys_sbrk+0x3c>
    return -1;
  return addr;
}
80104fba:	89 d8                	mov    %ebx,%eax
80104fbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104fbf:	c9                   	leave  
80104fc0:	c3                   	ret    
80104fc1:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104fc4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104fc9:	eb ef                	jmp    80104fba <sys_sbrk+0x32>
80104fcb:	90                   	nop

80104fcc <sys_sleep>:

int
sys_sleep(void)
{
80104fcc:	55                   	push   %ebp
80104fcd:	89 e5                	mov    %esp,%ebp
80104fcf:	53                   	push   %ebx
80104fd0:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104fd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104fd6:	50                   	push   %eax
80104fd7:	6a 00                	push   $0x0
80104fd9:	e8 72 f3 ff ff       	call   80104350 <argint>
80104fde:	83 c4 10             	add    $0x10,%esp
80104fe1:	85 c0                	test   %eax,%eax
80104fe3:	78 7e                	js     80105063 <sys_sleep+0x97>
    return -1;
  acquire(&tickslock);
80104fe5:	83 ec 0c             	sub    $0xc,%esp
80104fe8:	68 40 57 11 80       	push   $0x80115740
80104fed:	e8 5a f0 ff ff       	call   8010404c <acquire>
  ticks0 = ticks;
80104ff2:	8b 1d 80 5f 11 80    	mov    0x80115f80,%ebx
  while(ticks - ticks0 < n){
80104ff8:	83 c4 10             	add    $0x10,%esp
80104ffb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ffe:	85 d2                	test   %edx,%edx
80105000:	75 23                	jne    80105025 <sys_sleep+0x59>
80105002:	eb 48                	jmp    8010504c <sys_sleep+0x80>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105004:	83 ec 08             	sub    $0x8,%esp
80105007:	68 40 57 11 80       	push   $0x80115740
8010500c:	68 80 5f 11 80       	push   $0x80115f80
80105011:	e8 da e8 ff ff       	call   801038f0 <sleep>
  while(ticks - ticks0 < n){
80105016:	a1 80 5f 11 80       	mov    0x80115f80,%eax
8010501b:	29 d8                	sub    %ebx,%eax
8010501d:	83 c4 10             	add    $0x10,%esp
80105020:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105023:	73 27                	jae    8010504c <sys_sleep+0x80>
    if(myproc()->killed){
80105025:	e8 36 e3 ff ff       	call   80103360 <myproc>
8010502a:	8b 40 24             	mov    0x24(%eax),%eax
8010502d:	85 c0                	test   %eax,%eax
8010502f:	74 d3                	je     80105004 <sys_sleep+0x38>
      release(&tickslock);
80105031:	83 ec 0c             	sub    $0xc,%esp
80105034:	68 40 57 11 80       	push   $0x80115740
80105039:	e8 a6 f0 ff ff       	call   801040e4 <release>
      return -1;
8010503e:	83 c4 10             	add    $0x10,%esp
80105041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&tickslock);
  return 0;
}
80105046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105049:	c9                   	leave  
8010504a:	c3                   	ret    
8010504b:	90                   	nop
  release(&tickslock);
8010504c:	83 ec 0c             	sub    $0xc,%esp
8010504f:	68 40 57 11 80       	push   $0x80115740
80105054:	e8 8b f0 ff ff       	call   801040e4 <release>
  return 0;
80105059:	83 c4 10             	add    $0x10,%esp
8010505c:	31 c0                	xor    %eax,%eax
}
8010505e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105061:	c9                   	leave  
80105062:	c3                   	ret    
    return -1;
80105063:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105068:	eb f4                	jmp    8010505e <sys_sleep+0x92>
8010506a:	66 90                	xchg   %ax,%ax

8010506c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010506c:	55                   	push   %ebp
8010506d:	89 e5                	mov    %esp,%ebp
8010506f:	83 ec 24             	sub    $0x24,%esp
  uint xticks;

  acquire(&tickslock);
80105072:	68 40 57 11 80       	push   $0x80115740
80105077:	e8 d0 ef ff ff       	call   8010404c <acquire>
  xticks = ticks;
8010507c:	a1 80 5f 11 80       	mov    0x80115f80,%eax
80105081:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105084:	c7 04 24 40 57 11 80 	movl   $0x80115740,(%esp)
8010508b:	e8 54 f0 ff ff       	call   801040e4 <release>
  return xticks;
}
80105090:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105093:	c9                   	leave  
80105094:	c3                   	ret    

80105095 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105095:	1e                   	push   %ds
  pushl %es
80105096:	06                   	push   %es
  pushl %fs
80105097:	0f a0                	push   %fs
  pushl %gs
80105099:	0f a8                	push   %gs
  pushal
8010509b:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010509c:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801050a0:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801050a2:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801050a4:	54                   	push   %esp
  call trap
801050a5:	e8 9e 00 00 00       	call   80105148 <trap>
  addl $4, %esp
801050aa:	83 c4 04             	add    $0x4,%esp

801050ad <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801050ad:	61                   	popa   
  popl %gs
801050ae:	0f a9                	pop    %gs
  popl %fs
801050b0:	0f a1                	pop    %fs
  popl %es
801050b2:	07                   	pop    %es
  popl %ds
801050b3:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801050b4:	83 c4 08             	add    $0x8,%esp
  iret
801050b7:	cf                   	iret   

801050b8 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801050b8:	55                   	push   %ebp
801050b9:	89 e5                	mov    %esp,%ebp
801050bb:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
801050be:	31 c0                	xor    %eax,%eax
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801050c0:	8b 14 85 0c a0 10 80 	mov    -0x7fef5ff4(,%eax,4),%edx
801050c7:	66 89 14 c5 80 57 11 	mov    %dx,-0x7feea880(,%eax,8)
801050ce:	80 
801050cf:	c7 04 c5 82 57 11 80 	movl   $0x8e000008,-0x7feea87e(,%eax,8)
801050d6:	08 00 00 8e 
801050da:	c1 ea 10             	shr    $0x10,%edx
801050dd:	66 89 14 c5 86 57 11 	mov    %dx,-0x7feea87a(,%eax,8)
801050e4:	80 
  for(i = 0; i < 256; i++)
801050e5:	40                   	inc    %eax
801050e6:	3d 00 01 00 00       	cmp    $0x100,%eax
801050eb:	75 d3                	jne    801050c0 <tvinit+0x8>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801050ed:	a1 0c a1 10 80       	mov    0x8010a10c,%eax
801050f2:	66 a3 80 59 11 80    	mov    %ax,0x80115980
801050f8:	c7 05 82 59 11 80 08 	movl   $0xef000008,0x80115982
801050ff:	00 00 ef 
80105102:	c1 e8 10             	shr    $0x10,%eax
80105105:	66 a3 86 59 11 80    	mov    %ax,0x80115986

  initlock(&tickslock, "time");
8010510b:	83 ec 08             	sub    $0x8,%esp
8010510e:	68 3d 6f 10 80       	push   $0x80106f3d
80105113:	68 40 57 11 80       	push   $0x80115740
80105118:	e8 ef ed ff ff       	call   80103f0c <initlock>
}
8010511d:	83 c4 10             	add    $0x10,%esp
80105120:	c9                   	leave  
80105121:	c3                   	ret    
80105122:	66 90                	xchg   %ax,%ax

80105124 <idtinit>:

void
idtinit(void)
{
80105124:	55                   	push   %ebp
80105125:	89 e5                	mov    %esp,%ebp
80105127:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010512a:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105130:	b8 80 57 11 80       	mov    $0x80115780,%eax
80105135:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105139:	c1 e8 10             	shr    $0x10,%eax
8010513c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105140:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105143:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105146:	c9                   	leave  
80105147:	c3                   	ret    

80105148 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105148:	55                   	push   %ebp
80105149:	89 e5                	mov    %esp,%ebp
8010514b:	57                   	push   %edi
8010514c:	56                   	push   %esi
8010514d:	53                   	push   %ebx
8010514e:	83 ec 1c             	sub    $0x1c,%esp
80105151:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105154:	8b 43 30             	mov    0x30(%ebx),%eax
80105157:	83 f8 40             	cmp    $0x40,%eax
8010515a:	0f 84 b4 01 00 00    	je     80105314 <trap+0x1cc>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105160:	83 e8 20             	sub    $0x20,%eax
80105163:	83 f8 1f             	cmp    $0x1f,%eax
80105166:	77 07                	ja     8010516f <trap+0x27>
80105168:	ff 24 85 e4 6f 10 80 	jmp    *-0x7fef901c(,%eax,4)
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010516f:	e8 ec e1 ff ff       	call   80103360 <myproc>
80105174:	8b 7b 38             	mov    0x38(%ebx),%edi
80105177:	85 c0                	test   %eax,%eax
80105179:	0f 84 e0 01 00 00    	je     8010535f <trap+0x217>
8010517f:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105183:	0f 84 d6 01 00 00    	je     8010535f <trap+0x217>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105189:	0f 20 d1             	mov    %cr2,%ecx
8010518c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010518f:	e8 98 e1 ff ff       	call   8010332c <cpuid>
80105194:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105197:	8b 43 34             	mov    0x34(%ebx),%eax
8010519a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010519d:	8b 73 30             	mov    0x30(%ebx),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801051a0:	e8 bb e1 ff ff       	call   80103360 <myproc>
801051a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801051a8:	e8 b3 e1 ff ff       	call   80103360 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801051ad:	8b 4d d8             	mov    -0x28(%ebp),%ecx
801051b0:	51                   	push   %ecx
801051b1:	57                   	push   %edi
801051b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801051b5:	52                   	push   %edx
801051b6:	ff 75 e4             	pushl  -0x1c(%ebp)
801051b9:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
801051ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
801051bd:	83 c6 6c             	add    $0x6c,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801051c0:	56                   	push   %esi
801051c1:	ff 70 10             	pushl  0x10(%eax)
801051c4:	68 a0 6f 10 80       	push   $0x80106fa0
801051c9:	e8 52 b4 ff ff       	call   80100620 <cprintf>
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801051ce:	83 c4 20             	add    $0x20,%esp
801051d1:	e8 8a e1 ff ff       	call   80103360 <myproc>
801051d6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801051dd:	e8 7e e1 ff ff       	call   80103360 <myproc>
801051e2:	85 c0                	test   %eax,%eax
801051e4:	74 1c                	je     80105202 <trap+0xba>
801051e6:	e8 75 e1 ff ff       	call   80103360 <myproc>
801051eb:	8b 50 24             	mov    0x24(%eax),%edx
801051ee:	85 d2                	test   %edx,%edx
801051f0:	74 10                	je     80105202 <trap+0xba>
801051f2:	8b 43 3c             	mov    0x3c(%ebx),%eax
801051f5:	83 e0 03             	and    $0x3,%eax
801051f8:	66 83 f8 03          	cmp    $0x3,%ax
801051fc:	0f 84 4a 01 00 00    	je     8010534c <trap+0x204>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105202:	e8 59 e1 ff ff       	call   80103360 <myproc>
80105207:	85 c0                	test   %eax,%eax
80105209:	74 0f                	je     8010521a <trap+0xd2>
8010520b:	e8 50 e1 ff ff       	call   80103360 <myproc>
80105210:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105214:	0f 84 e6 00 00 00    	je     80105300 <trap+0x1b8>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010521a:	e8 41 e1 ff ff       	call   80103360 <myproc>
8010521f:	85 c0                	test   %eax,%eax
80105221:	74 1c                	je     8010523f <trap+0xf7>
80105223:	e8 38 e1 ff ff       	call   80103360 <myproc>
80105228:	8b 40 24             	mov    0x24(%eax),%eax
8010522b:	85 c0                	test   %eax,%eax
8010522d:	74 10                	je     8010523f <trap+0xf7>
8010522f:	8b 43 3c             	mov    0x3c(%ebx),%eax
80105232:	83 e0 03             	and    $0x3,%eax
80105235:	66 83 f8 03          	cmp    $0x3,%ax
80105239:	0f 84 fe 00 00 00    	je     8010533d <trap+0x1f5>
    exit();
}
8010523f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105242:	5b                   	pop    %ebx
80105243:	5e                   	pop    %esi
80105244:	5f                   	pop    %edi
80105245:	5d                   	pop    %ebp
80105246:	c3                   	ret    
    ideintr();
80105247:	e8 10 cc ff ff       	call   80101e5c <ideintr>
    lapiceoi();
8010524c:	e8 1f d2 ff ff       	call   80102470 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105251:	e8 0a e1 ff ff       	call   80103360 <myproc>
80105256:	85 c0                	test   %eax,%eax
80105258:	75 8c                	jne    801051e6 <trap+0x9e>
8010525a:	eb a6                	jmp    80105202 <trap+0xba>
    if(cpuid() == 0){
8010525c:	e8 cb e0 ff ff       	call   8010332c <cpuid>
80105261:	85 c0                	test   %eax,%eax
80105263:	75 e7                	jne    8010524c <trap+0x104>
      acquire(&tickslock);
80105265:	83 ec 0c             	sub    $0xc,%esp
80105268:	68 40 57 11 80       	push   $0x80115740
8010526d:	e8 da ed ff ff       	call   8010404c <acquire>
      ticks++;
80105272:	ff 05 80 5f 11 80    	incl   0x80115f80
      wakeup(&ticks);
80105278:	c7 04 24 80 5f 11 80 	movl   $0x80115f80,(%esp)
8010527f:	e8 18 e8 ff ff       	call   80103a9c <wakeup>
      release(&tickslock);
80105284:	c7 04 24 40 57 11 80 	movl   $0x80115740,(%esp)
8010528b:	e8 54 ee ff ff       	call   801040e4 <release>
80105290:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80105293:	eb b7                	jmp    8010524c <trap+0x104>
    kbdintr();
80105295:	e8 c6 d0 ff ff       	call   80102360 <kbdintr>
    lapiceoi();
8010529a:	e8 d1 d1 ff ff       	call   80102470 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010529f:	e8 bc e0 ff ff       	call   80103360 <myproc>
801052a4:	85 c0                	test   %eax,%eax
801052a6:	0f 85 3a ff ff ff    	jne    801051e6 <trap+0x9e>
801052ac:	e9 51 ff ff ff       	jmp    80105202 <trap+0xba>
    uartintr();
801052b1:	e8 fa 01 00 00       	call   801054b0 <uartintr>
    lapiceoi();
801052b6:	e8 b5 d1 ff ff       	call   80102470 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801052bb:	e8 a0 e0 ff ff       	call   80103360 <myproc>
801052c0:	85 c0                	test   %eax,%eax
801052c2:	0f 85 1e ff ff ff    	jne    801051e6 <trap+0x9e>
801052c8:	e9 35 ff ff ff       	jmp    80105202 <trap+0xba>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801052cd:	8b 7b 38             	mov    0x38(%ebx),%edi
801052d0:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
801052d4:	e8 53 e0 ff ff       	call   8010332c <cpuid>
801052d9:	57                   	push   %edi
801052da:	56                   	push   %esi
801052db:	50                   	push   %eax
801052dc:	68 48 6f 10 80       	push   $0x80106f48
801052e1:	e8 3a b3 ff ff       	call   80100620 <cprintf>
    lapiceoi();
801052e6:	e8 85 d1 ff ff       	call   80102470 <lapiceoi>
    break;
801052eb:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801052ee:	e8 6d e0 ff ff       	call   80103360 <myproc>
801052f3:	85 c0                	test   %eax,%eax
801052f5:	0f 85 eb fe ff ff    	jne    801051e6 <trap+0x9e>
801052fb:	e9 02 ff ff ff       	jmp    80105202 <trap+0xba>
  if(myproc() && myproc()->state == RUNNING &&
80105300:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105304:	0f 85 10 ff ff ff    	jne    8010521a <trap+0xd2>
    yield();
8010530a:	e8 99 e5 ff ff       	call   801038a8 <yield>
8010530f:	e9 06 ff ff ff       	jmp    8010521a <trap+0xd2>
    if(myproc()->killed)
80105314:	e8 47 e0 ff ff       	call   80103360 <myproc>
80105319:	8b 70 24             	mov    0x24(%eax),%esi
8010531c:	85 f6                	test   %esi,%esi
8010531e:	75 38                	jne    80105358 <trap+0x210>
    myproc()->tf = tf;
80105320:	e8 3b e0 ff ff       	call   80103360 <myproc>
80105325:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105328:	e8 ef f0 ff ff       	call   8010441c <syscall>
    if(myproc()->killed)
8010532d:	e8 2e e0 ff ff       	call   80103360 <myproc>
80105332:	8b 48 24             	mov    0x24(%eax),%ecx
80105335:	85 c9                	test   %ecx,%ecx
80105337:	0f 84 02 ff ff ff    	je     8010523f <trap+0xf7>
}
8010533d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105340:	5b                   	pop    %ebx
80105341:	5e                   	pop    %esi
80105342:	5f                   	pop    %edi
80105343:	5d                   	pop    %ebp
      exit();
80105344:	e9 43 e4 ff ff       	jmp    8010378c <exit>
80105349:	8d 76 00             	lea    0x0(%esi),%esi
    exit();
8010534c:	e8 3b e4 ff ff       	call   8010378c <exit>
80105351:	e9 ac fe ff ff       	jmp    80105202 <trap+0xba>
80105356:	66 90                	xchg   %ax,%ax
      exit();
80105358:	e8 2f e4 ff ff       	call   8010378c <exit>
8010535d:	eb c1                	jmp    80105320 <trap+0x1d8>
8010535f:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105362:	e8 c5 df ff ff       	call   8010332c <cpuid>
80105367:	83 ec 0c             	sub    $0xc,%esp
8010536a:	56                   	push   %esi
8010536b:	57                   	push   %edi
8010536c:	50                   	push   %eax
8010536d:	ff 73 30             	pushl  0x30(%ebx)
80105370:	68 6c 6f 10 80       	push   $0x80106f6c
80105375:	e8 a6 b2 ff ff       	call   80100620 <cprintf>
      panic("trap");
8010537a:	83 c4 14             	add    $0x14,%esp
8010537d:	68 42 6f 10 80       	push   $0x80106f42
80105382:	e8 b9 af ff ff       	call   80100340 <panic>
80105387:	90                   	nop

80105388 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105388:	a1 84 af 10 80       	mov    0x8010af84,%eax
8010538d:	85 c0                	test   %eax,%eax
8010538f:	74 17                	je     801053a8 <uartgetc+0x20>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105391:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105396:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105397:	a8 01                	test   $0x1,%al
80105399:	74 0d                	je     801053a8 <uartgetc+0x20>
8010539b:	ba f8 03 00 00       	mov    $0x3f8,%edx
801053a0:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801053a1:	0f b6 c0             	movzbl %al,%eax
801053a4:	c3                   	ret    
801053a5:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
801053a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053ad:	c3                   	ret    
801053ae:	66 90                	xchg   %ax,%ax

801053b0 <uartputc.part.0>:
uartputc(int c)
801053b0:	55                   	push   %ebp
801053b1:	89 e5                	mov    %esp,%ebp
801053b3:	57                   	push   %edi
801053b4:	56                   	push   %esi
801053b5:	53                   	push   %ebx
801053b6:	83 ec 0c             	sub    $0xc,%esp
801053b9:	89 c7                	mov    %eax,%edi
801053bb:	bb 80 00 00 00       	mov    $0x80,%ebx
801053c0:	be fd 03 00 00       	mov    $0x3fd,%esi
801053c5:	eb 11                	jmp    801053d8 <uartputc.part.0+0x28>
801053c7:	90                   	nop
    microdelay(10);
801053c8:	83 ec 0c             	sub    $0xc,%esp
801053cb:	6a 0a                	push   $0xa
801053cd:	e8 b6 d0 ff ff       	call   80102488 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801053d2:	83 c4 10             	add    $0x10,%esp
801053d5:	4b                   	dec    %ebx
801053d6:	74 07                	je     801053df <uartputc.part.0+0x2f>
801053d8:	89 f2                	mov    %esi,%edx
801053da:	ec                   	in     (%dx),%al
801053db:	a8 20                	test   $0x20,%al
801053dd:	74 e9                	je     801053c8 <uartputc.part.0+0x18>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801053df:	ba f8 03 00 00       	mov    $0x3f8,%edx
801053e4:	89 f8                	mov    %edi,%eax
801053e6:	ee                   	out    %al,(%dx)
}
801053e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801053ea:	5b                   	pop    %ebx
801053eb:	5e                   	pop    %esi
801053ec:	5f                   	pop    %edi
801053ed:	5d                   	pop    %ebp
801053ee:	c3                   	ret    
801053ef:	90                   	nop

801053f0 <uartinit>:
{
801053f0:	55                   	push   %ebp
801053f1:	89 e5                	mov    %esp,%ebp
801053f3:	57                   	push   %edi
801053f4:	56                   	push   %esi
801053f5:	53                   	push   %ebx
801053f6:	83 ec 1c             	sub    $0x1c,%esp
801053f9:	bb fa 03 00 00       	mov    $0x3fa,%ebx
801053fe:	31 c0                	xor    %eax,%eax
80105400:	89 da                	mov    %ebx,%edx
80105402:	ee                   	out    %al,(%dx)
80105403:	bf fb 03 00 00       	mov    $0x3fb,%edi
80105408:	b0 80                	mov    $0x80,%al
8010540a:	89 fa                	mov    %edi,%edx
8010540c:	ee                   	out    %al,(%dx)
8010540d:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
80105412:	b0 0c                	mov    $0xc,%al
80105414:	89 ca                	mov    %ecx,%edx
80105416:	ee                   	out    %al,(%dx)
80105417:	be f9 03 00 00       	mov    $0x3f9,%esi
8010541c:	31 c0                	xor    %eax,%eax
8010541e:	89 f2                	mov    %esi,%edx
80105420:	ee                   	out    %al,(%dx)
80105421:	b0 03                	mov    $0x3,%al
80105423:	89 fa                	mov    %edi,%edx
80105425:	ee                   	out    %al,(%dx)
80105426:	ba fc 03 00 00       	mov    $0x3fc,%edx
8010542b:	31 c0                	xor    %eax,%eax
8010542d:	ee                   	out    %al,(%dx)
8010542e:	b0 01                	mov    $0x1,%al
80105430:	89 f2                	mov    %esi,%edx
80105432:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105433:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105438:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105439:	fe c0                	inc    %al
8010543b:	74 4f                	je     8010548c <uartinit+0x9c>
  uart = 1;
8010543d:	c7 05 84 af 10 80 01 	movl   $0x1,0x8010af84
80105444:	00 00 00 
80105447:	89 da                	mov    %ebx,%edx
80105449:	ec                   	in     (%dx),%al
8010544a:	89 ca                	mov    %ecx,%edx
8010544c:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010544d:	83 ec 08             	sub    $0x8,%esp
80105450:	6a 00                	push   $0x0
80105452:	6a 04                	push   $0x4
80105454:	e8 17 cc ff ff       	call   80102070 <ioapicenable>
80105459:	83 c4 10             	add    $0x10,%esp
8010545c:	b2 76                	mov    $0x76,%dl
  for(p="xv6...\n"; *p; p++)
8010545e:	bb 64 70 10 80       	mov    $0x80107064,%ebx
80105463:	b8 78 00 00 00       	mov    $0x78,%eax
80105468:	eb 08                	jmp    80105472 <uartinit+0x82>
8010546a:	66 90                	xchg   %ax,%ax
8010546c:	0f be c2             	movsbl %dl,%eax
8010546f:	8a 53 01             	mov    0x1(%ebx),%dl
  if(!uart)
80105472:	8b 0d 84 af 10 80    	mov    0x8010af84,%ecx
80105478:	85 c9                	test   %ecx,%ecx
8010547a:	74 0b                	je     80105487 <uartinit+0x97>
8010547c:	88 55 e7             	mov    %dl,-0x19(%ebp)
8010547f:	e8 2c ff ff ff       	call   801053b0 <uartputc.part.0>
80105484:	8a 55 e7             	mov    -0x19(%ebp),%dl
  for(p="xv6...\n"; *p; p++)
80105487:	43                   	inc    %ebx
80105488:	84 d2                	test   %dl,%dl
8010548a:	75 e0                	jne    8010546c <uartinit+0x7c>
}
8010548c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010548f:	5b                   	pop    %ebx
80105490:	5e                   	pop    %esi
80105491:	5f                   	pop    %edi
80105492:	5d                   	pop    %ebp
80105493:	c3                   	ret    

80105494 <uartputc>:
{
80105494:	55                   	push   %ebp
80105495:	89 e5                	mov    %esp,%ebp
80105497:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!uart)
8010549a:	8b 15 84 af 10 80    	mov    0x8010af84,%edx
801054a0:	85 d2                	test   %edx,%edx
801054a2:	74 08                	je     801054ac <uartputc+0x18>
}
801054a4:	5d                   	pop    %ebp
801054a5:	e9 06 ff ff ff       	jmp    801053b0 <uartputc.part.0>
801054aa:	66 90                	xchg   %ax,%ax
801054ac:	5d                   	pop    %ebp
801054ad:	c3                   	ret    
801054ae:	66 90                	xchg   %ax,%ax

801054b0 <uartintr>:

void
uartintr(void)
{
801054b0:	55                   	push   %ebp
801054b1:	89 e5                	mov    %esp,%ebp
801054b3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801054b6:	68 88 53 10 80       	push   $0x80105388
801054bb:	e8 e8 b2 ff ff       	call   801007a8 <consoleintr>
}
801054c0:	83 c4 10             	add    $0x10,%esp
801054c3:	c9                   	leave  
801054c4:	c3                   	ret    

801054c5 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801054c5:	6a 00                	push   $0x0
  pushl $0
801054c7:	6a 00                	push   $0x0
  jmp alltraps
801054c9:	e9 c7 fb ff ff       	jmp    80105095 <alltraps>

801054ce <vector1>:
.globl vector1
vector1:
  pushl $0
801054ce:	6a 00                	push   $0x0
  pushl $1
801054d0:	6a 01                	push   $0x1
  jmp alltraps
801054d2:	e9 be fb ff ff       	jmp    80105095 <alltraps>

801054d7 <vector2>:
.globl vector2
vector2:
  pushl $0
801054d7:	6a 00                	push   $0x0
  pushl $2
801054d9:	6a 02                	push   $0x2
  jmp alltraps
801054db:	e9 b5 fb ff ff       	jmp    80105095 <alltraps>

801054e0 <vector3>:
.globl vector3
vector3:
  pushl $0
801054e0:	6a 00                	push   $0x0
  pushl $3
801054e2:	6a 03                	push   $0x3
  jmp alltraps
801054e4:	e9 ac fb ff ff       	jmp    80105095 <alltraps>

801054e9 <vector4>:
.globl vector4
vector4:
  pushl $0
801054e9:	6a 00                	push   $0x0
  pushl $4
801054eb:	6a 04                	push   $0x4
  jmp alltraps
801054ed:	e9 a3 fb ff ff       	jmp    80105095 <alltraps>

801054f2 <vector5>:
.globl vector5
vector5:
  pushl $0
801054f2:	6a 00                	push   $0x0
  pushl $5
801054f4:	6a 05                	push   $0x5
  jmp alltraps
801054f6:	e9 9a fb ff ff       	jmp    80105095 <alltraps>

801054fb <vector6>:
.globl vector6
vector6:
  pushl $0
801054fb:	6a 00                	push   $0x0
  pushl $6
801054fd:	6a 06                	push   $0x6
  jmp alltraps
801054ff:	e9 91 fb ff ff       	jmp    80105095 <alltraps>

80105504 <vector7>:
.globl vector7
vector7:
  pushl $0
80105504:	6a 00                	push   $0x0
  pushl $7
80105506:	6a 07                	push   $0x7
  jmp alltraps
80105508:	e9 88 fb ff ff       	jmp    80105095 <alltraps>

8010550d <vector8>:
.globl vector8
vector8:
  pushl $8
8010550d:	6a 08                	push   $0x8
  jmp alltraps
8010550f:	e9 81 fb ff ff       	jmp    80105095 <alltraps>

80105514 <vector9>:
.globl vector9
vector9:
  pushl $0
80105514:	6a 00                	push   $0x0
  pushl $9
80105516:	6a 09                	push   $0x9
  jmp alltraps
80105518:	e9 78 fb ff ff       	jmp    80105095 <alltraps>

8010551d <vector10>:
.globl vector10
vector10:
  pushl $10
8010551d:	6a 0a                	push   $0xa
  jmp alltraps
8010551f:	e9 71 fb ff ff       	jmp    80105095 <alltraps>

80105524 <vector11>:
.globl vector11
vector11:
  pushl $11
80105524:	6a 0b                	push   $0xb
  jmp alltraps
80105526:	e9 6a fb ff ff       	jmp    80105095 <alltraps>

8010552b <vector12>:
.globl vector12
vector12:
  pushl $12
8010552b:	6a 0c                	push   $0xc
  jmp alltraps
8010552d:	e9 63 fb ff ff       	jmp    80105095 <alltraps>

80105532 <vector13>:
.globl vector13
vector13:
  pushl $13
80105532:	6a 0d                	push   $0xd
  jmp alltraps
80105534:	e9 5c fb ff ff       	jmp    80105095 <alltraps>

80105539 <vector14>:
.globl vector14
vector14:
  pushl $14
80105539:	6a 0e                	push   $0xe
  jmp alltraps
8010553b:	e9 55 fb ff ff       	jmp    80105095 <alltraps>

80105540 <vector15>:
.globl vector15
vector15:
  pushl $0
80105540:	6a 00                	push   $0x0
  pushl $15
80105542:	6a 0f                	push   $0xf
  jmp alltraps
80105544:	e9 4c fb ff ff       	jmp    80105095 <alltraps>

80105549 <vector16>:
.globl vector16
vector16:
  pushl $0
80105549:	6a 00                	push   $0x0
  pushl $16
8010554b:	6a 10                	push   $0x10
  jmp alltraps
8010554d:	e9 43 fb ff ff       	jmp    80105095 <alltraps>

80105552 <vector17>:
.globl vector17
vector17:
  pushl $17
80105552:	6a 11                	push   $0x11
  jmp alltraps
80105554:	e9 3c fb ff ff       	jmp    80105095 <alltraps>

80105559 <vector18>:
.globl vector18
vector18:
  pushl $0
80105559:	6a 00                	push   $0x0
  pushl $18
8010555b:	6a 12                	push   $0x12
  jmp alltraps
8010555d:	e9 33 fb ff ff       	jmp    80105095 <alltraps>

80105562 <vector19>:
.globl vector19
vector19:
  pushl $0
80105562:	6a 00                	push   $0x0
  pushl $19
80105564:	6a 13                	push   $0x13
  jmp alltraps
80105566:	e9 2a fb ff ff       	jmp    80105095 <alltraps>

8010556b <vector20>:
.globl vector20
vector20:
  pushl $0
8010556b:	6a 00                	push   $0x0
  pushl $20
8010556d:	6a 14                	push   $0x14
  jmp alltraps
8010556f:	e9 21 fb ff ff       	jmp    80105095 <alltraps>

80105574 <vector21>:
.globl vector21
vector21:
  pushl $0
80105574:	6a 00                	push   $0x0
  pushl $21
80105576:	6a 15                	push   $0x15
  jmp alltraps
80105578:	e9 18 fb ff ff       	jmp    80105095 <alltraps>

8010557d <vector22>:
.globl vector22
vector22:
  pushl $0
8010557d:	6a 00                	push   $0x0
  pushl $22
8010557f:	6a 16                	push   $0x16
  jmp alltraps
80105581:	e9 0f fb ff ff       	jmp    80105095 <alltraps>

80105586 <vector23>:
.globl vector23
vector23:
  pushl $0
80105586:	6a 00                	push   $0x0
  pushl $23
80105588:	6a 17                	push   $0x17
  jmp alltraps
8010558a:	e9 06 fb ff ff       	jmp    80105095 <alltraps>

8010558f <vector24>:
.globl vector24
vector24:
  pushl $0
8010558f:	6a 00                	push   $0x0
  pushl $24
80105591:	6a 18                	push   $0x18
  jmp alltraps
80105593:	e9 fd fa ff ff       	jmp    80105095 <alltraps>

80105598 <vector25>:
.globl vector25
vector25:
  pushl $0
80105598:	6a 00                	push   $0x0
  pushl $25
8010559a:	6a 19                	push   $0x19
  jmp alltraps
8010559c:	e9 f4 fa ff ff       	jmp    80105095 <alltraps>

801055a1 <vector26>:
.globl vector26
vector26:
  pushl $0
801055a1:	6a 00                	push   $0x0
  pushl $26
801055a3:	6a 1a                	push   $0x1a
  jmp alltraps
801055a5:	e9 eb fa ff ff       	jmp    80105095 <alltraps>

801055aa <vector27>:
.globl vector27
vector27:
  pushl $0
801055aa:	6a 00                	push   $0x0
  pushl $27
801055ac:	6a 1b                	push   $0x1b
  jmp alltraps
801055ae:	e9 e2 fa ff ff       	jmp    80105095 <alltraps>

801055b3 <vector28>:
.globl vector28
vector28:
  pushl $0
801055b3:	6a 00                	push   $0x0
  pushl $28
801055b5:	6a 1c                	push   $0x1c
  jmp alltraps
801055b7:	e9 d9 fa ff ff       	jmp    80105095 <alltraps>

801055bc <vector29>:
.globl vector29
vector29:
  pushl $0
801055bc:	6a 00                	push   $0x0
  pushl $29
801055be:	6a 1d                	push   $0x1d
  jmp alltraps
801055c0:	e9 d0 fa ff ff       	jmp    80105095 <alltraps>

801055c5 <vector30>:
.globl vector30
vector30:
  pushl $0
801055c5:	6a 00                	push   $0x0
  pushl $30
801055c7:	6a 1e                	push   $0x1e
  jmp alltraps
801055c9:	e9 c7 fa ff ff       	jmp    80105095 <alltraps>

801055ce <vector31>:
.globl vector31
vector31:
  pushl $0
801055ce:	6a 00                	push   $0x0
  pushl $31
801055d0:	6a 1f                	push   $0x1f
  jmp alltraps
801055d2:	e9 be fa ff ff       	jmp    80105095 <alltraps>

801055d7 <vector32>:
.globl vector32
vector32:
  pushl $0
801055d7:	6a 00                	push   $0x0
  pushl $32
801055d9:	6a 20                	push   $0x20
  jmp alltraps
801055db:	e9 b5 fa ff ff       	jmp    80105095 <alltraps>

801055e0 <vector33>:
.globl vector33
vector33:
  pushl $0
801055e0:	6a 00                	push   $0x0
  pushl $33
801055e2:	6a 21                	push   $0x21
  jmp alltraps
801055e4:	e9 ac fa ff ff       	jmp    80105095 <alltraps>

801055e9 <vector34>:
.globl vector34
vector34:
  pushl $0
801055e9:	6a 00                	push   $0x0
  pushl $34
801055eb:	6a 22                	push   $0x22
  jmp alltraps
801055ed:	e9 a3 fa ff ff       	jmp    80105095 <alltraps>

801055f2 <vector35>:
.globl vector35
vector35:
  pushl $0
801055f2:	6a 00                	push   $0x0
  pushl $35
801055f4:	6a 23                	push   $0x23
  jmp alltraps
801055f6:	e9 9a fa ff ff       	jmp    80105095 <alltraps>

801055fb <vector36>:
.globl vector36
vector36:
  pushl $0
801055fb:	6a 00                	push   $0x0
  pushl $36
801055fd:	6a 24                	push   $0x24
  jmp alltraps
801055ff:	e9 91 fa ff ff       	jmp    80105095 <alltraps>

80105604 <vector37>:
.globl vector37
vector37:
  pushl $0
80105604:	6a 00                	push   $0x0
  pushl $37
80105606:	6a 25                	push   $0x25
  jmp alltraps
80105608:	e9 88 fa ff ff       	jmp    80105095 <alltraps>

8010560d <vector38>:
.globl vector38
vector38:
  pushl $0
8010560d:	6a 00                	push   $0x0
  pushl $38
8010560f:	6a 26                	push   $0x26
  jmp alltraps
80105611:	e9 7f fa ff ff       	jmp    80105095 <alltraps>

80105616 <vector39>:
.globl vector39
vector39:
  pushl $0
80105616:	6a 00                	push   $0x0
  pushl $39
80105618:	6a 27                	push   $0x27
  jmp alltraps
8010561a:	e9 76 fa ff ff       	jmp    80105095 <alltraps>

8010561f <vector40>:
.globl vector40
vector40:
  pushl $0
8010561f:	6a 00                	push   $0x0
  pushl $40
80105621:	6a 28                	push   $0x28
  jmp alltraps
80105623:	e9 6d fa ff ff       	jmp    80105095 <alltraps>

80105628 <vector41>:
.globl vector41
vector41:
  pushl $0
80105628:	6a 00                	push   $0x0
  pushl $41
8010562a:	6a 29                	push   $0x29
  jmp alltraps
8010562c:	e9 64 fa ff ff       	jmp    80105095 <alltraps>

80105631 <vector42>:
.globl vector42
vector42:
  pushl $0
80105631:	6a 00                	push   $0x0
  pushl $42
80105633:	6a 2a                	push   $0x2a
  jmp alltraps
80105635:	e9 5b fa ff ff       	jmp    80105095 <alltraps>

8010563a <vector43>:
.globl vector43
vector43:
  pushl $0
8010563a:	6a 00                	push   $0x0
  pushl $43
8010563c:	6a 2b                	push   $0x2b
  jmp alltraps
8010563e:	e9 52 fa ff ff       	jmp    80105095 <alltraps>

80105643 <vector44>:
.globl vector44
vector44:
  pushl $0
80105643:	6a 00                	push   $0x0
  pushl $44
80105645:	6a 2c                	push   $0x2c
  jmp alltraps
80105647:	e9 49 fa ff ff       	jmp    80105095 <alltraps>

8010564c <vector45>:
.globl vector45
vector45:
  pushl $0
8010564c:	6a 00                	push   $0x0
  pushl $45
8010564e:	6a 2d                	push   $0x2d
  jmp alltraps
80105650:	e9 40 fa ff ff       	jmp    80105095 <alltraps>

80105655 <vector46>:
.globl vector46
vector46:
  pushl $0
80105655:	6a 00                	push   $0x0
  pushl $46
80105657:	6a 2e                	push   $0x2e
  jmp alltraps
80105659:	e9 37 fa ff ff       	jmp    80105095 <alltraps>

8010565e <vector47>:
.globl vector47
vector47:
  pushl $0
8010565e:	6a 00                	push   $0x0
  pushl $47
80105660:	6a 2f                	push   $0x2f
  jmp alltraps
80105662:	e9 2e fa ff ff       	jmp    80105095 <alltraps>

80105667 <vector48>:
.globl vector48
vector48:
  pushl $0
80105667:	6a 00                	push   $0x0
  pushl $48
80105669:	6a 30                	push   $0x30
  jmp alltraps
8010566b:	e9 25 fa ff ff       	jmp    80105095 <alltraps>

80105670 <vector49>:
.globl vector49
vector49:
  pushl $0
80105670:	6a 00                	push   $0x0
  pushl $49
80105672:	6a 31                	push   $0x31
  jmp alltraps
80105674:	e9 1c fa ff ff       	jmp    80105095 <alltraps>

80105679 <vector50>:
.globl vector50
vector50:
  pushl $0
80105679:	6a 00                	push   $0x0
  pushl $50
8010567b:	6a 32                	push   $0x32
  jmp alltraps
8010567d:	e9 13 fa ff ff       	jmp    80105095 <alltraps>

80105682 <vector51>:
.globl vector51
vector51:
  pushl $0
80105682:	6a 00                	push   $0x0
  pushl $51
80105684:	6a 33                	push   $0x33
  jmp alltraps
80105686:	e9 0a fa ff ff       	jmp    80105095 <alltraps>

8010568b <vector52>:
.globl vector52
vector52:
  pushl $0
8010568b:	6a 00                	push   $0x0
  pushl $52
8010568d:	6a 34                	push   $0x34
  jmp alltraps
8010568f:	e9 01 fa ff ff       	jmp    80105095 <alltraps>

80105694 <vector53>:
.globl vector53
vector53:
  pushl $0
80105694:	6a 00                	push   $0x0
  pushl $53
80105696:	6a 35                	push   $0x35
  jmp alltraps
80105698:	e9 f8 f9 ff ff       	jmp    80105095 <alltraps>

8010569d <vector54>:
.globl vector54
vector54:
  pushl $0
8010569d:	6a 00                	push   $0x0
  pushl $54
8010569f:	6a 36                	push   $0x36
  jmp alltraps
801056a1:	e9 ef f9 ff ff       	jmp    80105095 <alltraps>

801056a6 <vector55>:
.globl vector55
vector55:
  pushl $0
801056a6:	6a 00                	push   $0x0
  pushl $55
801056a8:	6a 37                	push   $0x37
  jmp alltraps
801056aa:	e9 e6 f9 ff ff       	jmp    80105095 <alltraps>

801056af <vector56>:
.globl vector56
vector56:
  pushl $0
801056af:	6a 00                	push   $0x0
  pushl $56
801056b1:	6a 38                	push   $0x38
  jmp alltraps
801056b3:	e9 dd f9 ff ff       	jmp    80105095 <alltraps>

801056b8 <vector57>:
.globl vector57
vector57:
  pushl $0
801056b8:	6a 00                	push   $0x0
  pushl $57
801056ba:	6a 39                	push   $0x39
  jmp alltraps
801056bc:	e9 d4 f9 ff ff       	jmp    80105095 <alltraps>

801056c1 <vector58>:
.globl vector58
vector58:
  pushl $0
801056c1:	6a 00                	push   $0x0
  pushl $58
801056c3:	6a 3a                	push   $0x3a
  jmp alltraps
801056c5:	e9 cb f9 ff ff       	jmp    80105095 <alltraps>

801056ca <vector59>:
.globl vector59
vector59:
  pushl $0
801056ca:	6a 00                	push   $0x0
  pushl $59
801056cc:	6a 3b                	push   $0x3b
  jmp alltraps
801056ce:	e9 c2 f9 ff ff       	jmp    80105095 <alltraps>

801056d3 <vector60>:
.globl vector60
vector60:
  pushl $0
801056d3:	6a 00                	push   $0x0
  pushl $60
801056d5:	6a 3c                	push   $0x3c
  jmp alltraps
801056d7:	e9 b9 f9 ff ff       	jmp    80105095 <alltraps>

801056dc <vector61>:
.globl vector61
vector61:
  pushl $0
801056dc:	6a 00                	push   $0x0
  pushl $61
801056de:	6a 3d                	push   $0x3d
  jmp alltraps
801056e0:	e9 b0 f9 ff ff       	jmp    80105095 <alltraps>

801056e5 <vector62>:
.globl vector62
vector62:
  pushl $0
801056e5:	6a 00                	push   $0x0
  pushl $62
801056e7:	6a 3e                	push   $0x3e
  jmp alltraps
801056e9:	e9 a7 f9 ff ff       	jmp    80105095 <alltraps>

801056ee <vector63>:
.globl vector63
vector63:
  pushl $0
801056ee:	6a 00                	push   $0x0
  pushl $63
801056f0:	6a 3f                	push   $0x3f
  jmp alltraps
801056f2:	e9 9e f9 ff ff       	jmp    80105095 <alltraps>

801056f7 <vector64>:
.globl vector64
vector64:
  pushl $0
801056f7:	6a 00                	push   $0x0
  pushl $64
801056f9:	6a 40                	push   $0x40
  jmp alltraps
801056fb:	e9 95 f9 ff ff       	jmp    80105095 <alltraps>

80105700 <vector65>:
.globl vector65
vector65:
  pushl $0
80105700:	6a 00                	push   $0x0
  pushl $65
80105702:	6a 41                	push   $0x41
  jmp alltraps
80105704:	e9 8c f9 ff ff       	jmp    80105095 <alltraps>

80105709 <vector66>:
.globl vector66
vector66:
  pushl $0
80105709:	6a 00                	push   $0x0
  pushl $66
8010570b:	6a 42                	push   $0x42
  jmp alltraps
8010570d:	e9 83 f9 ff ff       	jmp    80105095 <alltraps>

80105712 <vector67>:
.globl vector67
vector67:
  pushl $0
80105712:	6a 00                	push   $0x0
  pushl $67
80105714:	6a 43                	push   $0x43
  jmp alltraps
80105716:	e9 7a f9 ff ff       	jmp    80105095 <alltraps>

8010571b <vector68>:
.globl vector68
vector68:
  pushl $0
8010571b:	6a 00                	push   $0x0
  pushl $68
8010571d:	6a 44                	push   $0x44
  jmp alltraps
8010571f:	e9 71 f9 ff ff       	jmp    80105095 <alltraps>

80105724 <vector69>:
.globl vector69
vector69:
  pushl $0
80105724:	6a 00                	push   $0x0
  pushl $69
80105726:	6a 45                	push   $0x45
  jmp alltraps
80105728:	e9 68 f9 ff ff       	jmp    80105095 <alltraps>

8010572d <vector70>:
.globl vector70
vector70:
  pushl $0
8010572d:	6a 00                	push   $0x0
  pushl $70
8010572f:	6a 46                	push   $0x46
  jmp alltraps
80105731:	e9 5f f9 ff ff       	jmp    80105095 <alltraps>

80105736 <vector71>:
.globl vector71
vector71:
  pushl $0
80105736:	6a 00                	push   $0x0
  pushl $71
80105738:	6a 47                	push   $0x47
  jmp alltraps
8010573a:	e9 56 f9 ff ff       	jmp    80105095 <alltraps>

8010573f <vector72>:
.globl vector72
vector72:
  pushl $0
8010573f:	6a 00                	push   $0x0
  pushl $72
80105741:	6a 48                	push   $0x48
  jmp alltraps
80105743:	e9 4d f9 ff ff       	jmp    80105095 <alltraps>

80105748 <vector73>:
.globl vector73
vector73:
  pushl $0
80105748:	6a 00                	push   $0x0
  pushl $73
8010574a:	6a 49                	push   $0x49
  jmp alltraps
8010574c:	e9 44 f9 ff ff       	jmp    80105095 <alltraps>

80105751 <vector74>:
.globl vector74
vector74:
  pushl $0
80105751:	6a 00                	push   $0x0
  pushl $74
80105753:	6a 4a                	push   $0x4a
  jmp alltraps
80105755:	e9 3b f9 ff ff       	jmp    80105095 <alltraps>

8010575a <vector75>:
.globl vector75
vector75:
  pushl $0
8010575a:	6a 00                	push   $0x0
  pushl $75
8010575c:	6a 4b                	push   $0x4b
  jmp alltraps
8010575e:	e9 32 f9 ff ff       	jmp    80105095 <alltraps>

80105763 <vector76>:
.globl vector76
vector76:
  pushl $0
80105763:	6a 00                	push   $0x0
  pushl $76
80105765:	6a 4c                	push   $0x4c
  jmp alltraps
80105767:	e9 29 f9 ff ff       	jmp    80105095 <alltraps>

8010576c <vector77>:
.globl vector77
vector77:
  pushl $0
8010576c:	6a 00                	push   $0x0
  pushl $77
8010576e:	6a 4d                	push   $0x4d
  jmp alltraps
80105770:	e9 20 f9 ff ff       	jmp    80105095 <alltraps>

80105775 <vector78>:
.globl vector78
vector78:
  pushl $0
80105775:	6a 00                	push   $0x0
  pushl $78
80105777:	6a 4e                	push   $0x4e
  jmp alltraps
80105779:	e9 17 f9 ff ff       	jmp    80105095 <alltraps>

8010577e <vector79>:
.globl vector79
vector79:
  pushl $0
8010577e:	6a 00                	push   $0x0
  pushl $79
80105780:	6a 4f                	push   $0x4f
  jmp alltraps
80105782:	e9 0e f9 ff ff       	jmp    80105095 <alltraps>

80105787 <vector80>:
.globl vector80
vector80:
  pushl $0
80105787:	6a 00                	push   $0x0
  pushl $80
80105789:	6a 50                	push   $0x50
  jmp alltraps
8010578b:	e9 05 f9 ff ff       	jmp    80105095 <alltraps>

80105790 <vector81>:
.globl vector81
vector81:
  pushl $0
80105790:	6a 00                	push   $0x0
  pushl $81
80105792:	6a 51                	push   $0x51
  jmp alltraps
80105794:	e9 fc f8 ff ff       	jmp    80105095 <alltraps>

80105799 <vector82>:
.globl vector82
vector82:
  pushl $0
80105799:	6a 00                	push   $0x0
  pushl $82
8010579b:	6a 52                	push   $0x52
  jmp alltraps
8010579d:	e9 f3 f8 ff ff       	jmp    80105095 <alltraps>

801057a2 <vector83>:
.globl vector83
vector83:
  pushl $0
801057a2:	6a 00                	push   $0x0
  pushl $83
801057a4:	6a 53                	push   $0x53
  jmp alltraps
801057a6:	e9 ea f8 ff ff       	jmp    80105095 <alltraps>

801057ab <vector84>:
.globl vector84
vector84:
  pushl $0
801057ab:	6a 00                	push   $0x0
  pushl $84
801057ad:	6a 54                	push   $0x54
  jmp alltraps
801057af:	e9 e1 f8 ff ff       	jmp    80105095 <alltraps>

801057b4 <vector85>:
.globl vector85
vector85:
  pushl $0
801057b4:	6a 00                	push   $0x0
  pushl $85
801057b6:	6a 55                	push   $0x55
  jmp alltraps
801057b8:	e9 d8 f8 ff ff       	jmp    80105095 <alltraps>

801057bd <vector86>:
.globl vector86
vector86:
  pushl $0
801057bd:	6a 00                	push   $0x0
  pushl $86
801057bf:	6a 56                	push   $0x56
  jmp alltraps
801057c1:	e9 cf f8 ff ff       	jmp    80105095 <alltraps>

801057c6 <vector87>:
.globl vector87
vector87:
  pushl $0
801057c6:	6a 00                	push   $0x0
  pushl $87
801057c8:	6a 57                	push   $0x57
  jmp alltraps
801057ca:	e9 c6 f8 ff ff       	jmp    80105095 <alltraps>

801057cf <vector88>:
.globl vector88
vector88:
  pushl $0
801057cf:	6a 00                	push   $0x0
  pushl $88
801057d1:	6a 58                	push   $0x58
  jmp alltraps
801057d3:	e9 bd f8 ff ff       	jmp    80105095 <alltraps>

801057d8 <vector89>:
.globl vector89
vector89:
  pushl $0
801057d8:	6a 00                	push   $0x0
  pushl $89
801057da:	6a 59                	push   $0x59
  jmp alltraps
801057dc:	e9 b4 f8 ff ff       	jmp    80105095 <alltraps>

801057e1 <vector90>:
.globl vector90
vector90:
  pushl $0
801057e1:	6a 00                	push   $0x0
  pushl $90
801057e3:	6a 5a                	push   $0x5a
  jmp alltraps
801057e5:	e9 ab f8 ff ff       	jmp    80105095 <alltraps>

801057ea <vector91>:
.globl vector91
vector91:
  pushl $0
801057ea:	6a 00                	push   $0x0
  pushl $91
801057ec:	6a 5b                	push   $0x5b
  jmp alltraps
801057ee:	e9 a2 f8 ff ff       	jmp    80105095 <alltraps>

801057f3 <vector92>:
.globl vector92
vector92:
  pushl $0
801057f3:	6a 00                	push   $0x0
  pushl $92
801057f5:	6a 5c                	push   $0x5c
  jmp alltraps
801057f7:	e9 99 f8 ff ff       	jmp    80105095 <alltraps>

801057fc <vector93>:
.globl vector93
vector93:
  pushl $0
801057fc:	6a 00                	push   $0x0
  pushl $93
801057fe:	6a 5d                	push   $0x5d
  jmp alltraps
80105800:	e9 90 f8 ff ff       	jmp    80105095 <alltraps>

80105805 <vector94>:
.globl vector94
vector94:
  pushl $0
80105805:	6a 00                	push   $0x0
  pushl $94
80105807:	6a 5e                	push   $0x5e
  jmp alltraps
80105809:	e9 87 f8 ff ff       	jmp    80105095 <alltraps>

8010580e <vector95>:
.globl vector95
vector95:
  pushl $0
8010580e:	6a 00                	push   $0x0
  pushl $95
80105810:	6a 5f                	push   $0x5f
  jmp alltraps
80105812:	e9 7e f8 ff ff       	jmp    80105095 <alltraps>

80105817 <vector96>:
.globl vector96
vector96:
  pushl $0
80105817:	6a 00                	push   $0x0
  pushl $96
80105819:	6a 60                	push   $0x60
  jmp alltraps
8010581b:	e9 75 f8 ff ff       	jmp    80105095 <alltraps>

80105820 <vector97>:
.globl vector97
vector97:
  pushl $0
80105820:	6a 00                	push   $0x0
  pushl $97
80105822:	6a 61                	push   $0x61
  jmp alltraps
80105824:	e9 6c f8 ff ff       	jmp    80105095 <alltraps>

80105829 <vector98>:
.globl vector98
vector98:
  pushl $0
80105829:	6a 00                	push   $0x0
  pushl $98
8010582b:	6a 62                	push   $0x62
  jmp alltraps
8010582d:	e9 63 f8 ff ff       	jmp    80105095 <alltraps>

80105832 <vector99>:
.globl vector99
vector99:
  pushl $0
80105832:	6a 00                	push   $0x0
  pushl $99
80105834:	6a 63                	push   $0x63
  jmp alltraps
80105836:	e9 5a f8 ff ff       	jmp    80105095 <alltraps>

8010583b <vector100>:
.globl vector100
vector100:
  pushl $0
8010583b:	6a 00                	push   $0x0
  pushl $100
8010583d:	6a 64                	push   $0x64
  jmp alltraps
8010583f:	e9 51 f8 ff ff       	jmp    80105095 <alltraps>

80105844 <vector101>:
.globl vector101
vector101:
  pushl $0
80105844:	6a 00                	push   $0x0
  pushl $101
80105846:	6a 65                	push   $0x65
  jmp alltraps
80105848:	e9 48 f8 ff ff       	jmp    80105095 <alltraps>

8010584d <vector102>:
.globl vector102
vector102:
  pushl $0
8010584d:	6a 00                	push   $0x0
  pushl $102
8010584f:	6a 66                	push   $0x66
  jmp alltraps
80105851:	e9 3f f8 ff ff       	jmp    80105095 <alltraps>

80105856 <vector103>:
.globl vector103
vector103:
  pushl $0
80105856:	6a 00                	push   $0x0
  pushl $103
80105858:	6a 67                	push   $0x67
  jmp alltraps
8010585a:	e9 36 f8 ff ff       	jmp    80105095 <alltraps>

8010585f <vector104>:
.globl vector104
vector104:
  pushl $0
8010585f:	6a 00                	push   $0x0
  pushl $104
80105861:	6a 68                	push   $0x68
  jmp alltraps
80105863:	e9 2d f8 ff ff       	jmp    80105095 <alltraps>

80105868 <vector105>:
.globl vector105
vector105:
  pushl $0
80105868:	6a 00                	push   $0x0
  pushl $105
8010586a:	6a 69                	push   $0x69
  jmp alltraps
8010586c:	e9 24 f8 ff ff       	jmp    80105095 <alltraps>

80105871 <vector106>:
.globl vector106
vector106:
  pushl $0
80105871:	6a 00                	push   $0x0
  pushl $106
80105873:	6a 6a                	push   $0x6a
  jmp alltraps
80105875:	e9 1b f8 ff ff       	jmp    80105095 <alltraps>

8010587a <vector107>:
.globl vector107
vector107:
  pushl $0
8010587a:	6a 00                	push   $0x0
  pushl $107
8010587c:	6a 6b                	push   $0x6b
  jmp alltraps
8010587e:	e9 12 f8 ff ff       	jmp    80105095 <alltraps>

80105883 <vector108>:
.globl vector108
vector108:
  pushl $0
80105883:	6a 00                	push   $0x0
  pushl $108
80105885:	6a 6c                	push   $0x6c
  jmp alltraps
80105887:	e9 09 f8 ff ff       	jmp    80105095 <alltraps>

8010588c <vector109>:
.globl vector109
vector109:
  pushl $0
8010588c:	6a 00                	push   $0x0
  pushl $109
8010588e:	6a 6d                	push   $0x6d
  jmp alltraps
80105890:	e9 00 f8 ff ff       	jmp    80105095 <alltraps>

80105895 <vector110>:
.globl vector110
vector110:
  pushl $0
80105895:	6a 00                	push   $0x0
  pushl $110
80105897:	6a 6e                	push   $0x6e
  jmp alltraps
80105899:	e9 f7 f7 ff ff       	jmp    80105095 <alltraps>

8010589e <vector111>:
.globl vector111
vector111:
  pushl $0
8010589e:	6a 00                	push   $0x0
  pushl $111
801058a0:	6a 6f                	push   $0x6f
  jmp alltraps
801058a2:	e9 ee f7 ff ff       	jmp    80105095 <alltraps>

801058a7 <vector112>:
.globl vector112
vector112:
  pushl $0
801058a7:	6a 00                	push   $0x0
  pushl $112
801058a9:	6a 70                	push   $0x70
  jmp alltraps
801058ab:	e9 e5 f7 ff ff       	jmp    80105095 <alltraps>

801058b0 <vector113>:
.globl vector113
vector113:
  pushl $0
801058b0:	6a 00                	push   $0x0
  pushl $113
801058b2:	6a 71                	push   $0x71
  jmp alltraps
801058b4:	e9 dc f7 ff ff       	jmp    80105095 <alltraps>

801058b9 <vector114>:
.globl vector114
vector114:
  pushl $0
801058b9:	6a 00                	push   $0x0
  pushl $114
801058bb:	6a 72                	push   $0x72
  jmp alltraps
801058bd:	e9 d3 f7 ff ff       	jmp    80105095 <alltraps>

801058c2 <vector115>:
.globl vector115
vector115:
  pushl $0
801058c2:	6a 00                	push   $0x0
  pushl $115
801058c4:	6a 73                	push   $0x73
  jmp alltraps
801058c6:	e9 ca f7 ff ff       	jmp    80105095 <alltraps>

801058cb <vector116>:
.globl vector116
vector116:
  pushl $0
801058cb:	6a 00                	push   $0x0
  pushl $116
801058cd:	6a 74                	push   $0x74
  jmp alltraps
801058cf:	e9 c1 f7 ff ff       	jmp    80105095 <alltraps>

801058d4 <vector117>:
.globl vector117
vector117:
  pushl $0
801058d4:	6a 00                	push   $0x0
  pushl $117
801058d6:	6a 75                	push   $0x75
  jmp alltraps
801058d8:	e9 b8 f7 ff ff       	jmp    80105095 <alltraps>

801058dd <vector118>:
.globl vector118
vector118:
  pushl $0
801058dd:	6a 00                	push   $0x0
  pushl $118
801058df:	6a 76                	push   $0x76
  jmp alltraps
801058e1:	e9 af f7 ff ff       	jmp    80105095 <alltraps>

801058e6 <vector119>:
.globl vector119
vector119:
  pushl $0
801058e6:	6a 00                	push   $0x0
  pushl $119
801058e8:	6a 77                	push   $0x77
  jmp alltraps
801058ea:	e9 a6 f7 ff ff       	jmp    80105095 <alltraps>

801058ef <vector120>:
.globl vector120
vector120:
  pushl $0
801058ef:	6a 00                	push   $0x0
  pushl $120
801058f1:	6a 78                	push   $0x78
  jmp alltraps
801058f3:	e9 9d f7 ff ff       	jmp    80105095 <alltraps>

801058f8 <vector121>:
.globl vector121
vector121:
  pushl $0
801058f8:	6a 00                	push   $0x0
  pushl $121
801058fa:	6a 79                	push   $0x79
  jmp alltraps
801058fc:	e9 94 f7 ff ff       	jmp    80105095 <alltraps>

80105901 <vector122>:
.globl vector122
vector122:
  pushl $0
80105901:	6a 00                	push   $0x0
  pushl $122
80105903:	6a 7a                	push   $0x7a
  jmp alltraps
80105905:	e9 8b f7 ff ff       	jmp    80105095 <alltraps>

8010590a <vector123>:
.globl vector123
vector123:
  pushl $0
8010590a:	6a 00                	push   $0x0
  pushl $123
8010590c:	6a 7b                	push   $0x7b
  jmp alltraps
8010590e:	e9 82 f7 ff ff       	jmp    80105095 <alltraps>

80105913 <vector124>:
.globl vector124
vector124:
  pushl $0
80105913:	6a 00                	push   $0x0
  pushl $124
80105915:	6a 7c                	push   $0x7c
  jmp alltraps
80105917:	e9 79 f7 ff ff       	jmp    80105095 <alltraps>

8010591c <vector125>:
.globl vector125
vector125:
  pushl $0
8010591c:	6a 00                	push   $0x0
  pushl $125
8010591e:	6a 7d                	push   $0x7d
  jmp alltraps
80105920:	e9 70 f7 ff ff       	jmp    80105095 <alltraps>

80105925 <vector126>:
.globl vector126
vector126:
  pushl $0
80105925:	6a 00                	push   $0x0
  pushl $126
80105927:	6a 7e                	push   $0x7e
  jmp alltraps
80105929:	e9 67 f7 ff ff       	jmp    80105095 <alltraps>

8010592e <vector127>:
.globl vector127
vector127:
  pushl $0
8010592e:	6a 00                	push   $0x0
  pushl $127
80105930:	6a 7f                	push   $0x7f
  jmp alltraps
80105932:	e9 5e f7 ff ff       	jmp    80105095 <alltraps>

80105937 <vector128>:
.globl vector128
vector128:
  pushl $0
80105937:	6a 00                	push   $0x0
  pushl $128
80105939:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010593e:	e9 52 f7 ff ff       	jmp    80105095 <alltraps>

80105943 <vector129>:
.globl vector129
vector129:
  pushl $0
80105943:	6a 00                	push   $0x0
  pushl $129
80105945:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010594a:	e9 46 f7 ff ff       	jmp    80105095 <alltraps>

8010594f <vector130>:
.globl vector130
vector130:
  pushl $0
8010594f:	6a 00                	push   $0x0
  pushl $130
80105951:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105956:	e9 3a f7 ff ff       	jmp    80105095 <alltraps>

8010595b <vector131>:
.globl vector131
vector131:
  pushl $0
8010595b:	6a 00                	push   $0x0
  pushl $131
8010595d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105962:	e9 2e f7 ff ff       	jmp    80105095 <alltraps>

80105967 <vector132>:
.globl vector132
vector132:
  pushl $0
80105967:	6a 00                	push   $0x0
  pushl $132
80105969:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010596e:	e9 22 f7 ff ff       	jmp    80105095 <alltraps>

80105973 <vector133>:
.globl vector133
vector133:
  pushl $0
80105973:	6a 00                	push   $0x0
  pushl $133
80105975:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010597a:	e9 16 f7 ff ff       	jmp    80105095 <alltraps>

8010597f <vector134>:
.globl vector134
vector134:
  pushl $0
8010597f:	6a 00                	push   $0x0
  pushl $134
80105981:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105986:	e9 0a f7 ff ff       	jmp    80105095 <alltraps>

8010598b <vector135>:
.globl vector135
vector135:
  pushl $0
8010598b:	6a 00                	push   $0x0
  pushl $135
8010598d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105992:	e9 fe f6 ff ff       	jmp    80105095 <alltraps>

80105997 <vector136>:
.globl vector136
vector136:
  pushl $0
80105997:	6a 00                	push   $0x0
  pushl $136
80105999:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010599e:	e9 f2 f6 ff ff       	jmp    80105095 <alltraps>

801059a3 <vector137>:
.globl vector137
vector137:
  pushl $0
801059a3:	6a 00                	push   $0x0
  pushl $137
801059a5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801059aa:	e9 e6 f6 ff ff       	jmp    80105095 <alltraps>

801059af <vector138>:
.globl vector138
vector138:
  pushl $0
801059af:	6a 00                	push   $0x0
  pushl $138
801059b1:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801059b6:	e9 da f6 ff ff       	jmp    80105095 <alltraps>

801059bb <vector139>:
.globl vector139
vector139:
  pushl $0
801059bb:	6a 00                	push   $0x0
  pushl $139
801059bd:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801059c2:	e9 ce f6 ff ff       	jmp    80105095 <alltraps>

801059c7 <vector140>:
.globl vector140
vector140:
  pushl $0
801059c7:	6a 00                	push   $0x0
  pushl $140
801059c9:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801059ce:	e9 c2 f6 ff ff       	jmp    80105095 <alltraps>

801059d3 <vector141>:
.globl vector141
vector141:
  pushl $0
801059d3:	6a 00                	push   $0x0
  pushl $141
801059d5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801059da:	e9 b6 f6 ff ff       	jmp    80105095 <alltraps>

801059df <vector142>:
.globl vector142
vector142:
  pushl $0
801059df:	6a 00                	push   $0x0
  pushl $142
801059e1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801059e6:	e9 aa f6 ff ff       	jmp    80105095 <alltraps>

801059eb <vector143>:
.globl vector143
vector143:
  pushl $0
801059eb:	6a 00                	push   $0x0
  pushl $143
801059ed:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801059f2:	e9 9e f6 ff ff       	jmp    80105095 <alltraps>

801059f7 <vector144>:
.globl vector144
vector144:
  pushl $0
801059f7:	6a 00                	push   $0x0
  pushl $144
801059f9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801059fe:	e9 92 f6 ff ff       	jmp    80105095 <alltraps>

80105a03 <vector145>:
.globl vector145
vector145:
  pushl $0
80105a03:	6a 00                	push   $0x0
  pushl $145
80105a05:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105a0a:	e9 86 f6 ff ff       	jmp    80105095 <alltraps>

80105a0f <vector146>:
.globl vector146
vector146:
  pushl $0
80105a0f:	6a 00                	push   $0x0
  pushl $146
80105a11:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105a16:	e9 7a f6 ff ff       	jmp    80105095 <alltraps>

80105a1b <vector147>:
.globl vector147
vector147:
  pushl $0
80105a1b:	6a 00                	push   $0x0
  pushl $147
80105a1d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105a22:	e9 6e f6 ff ff       	jmp    80105095 <alltraps>

80105a27 <vector148>:
.globl vector148
vector148:
  pushl $0
80105a27:	6a 00                	push   $0x0
  pushl $148
80105a29:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105a2e:	e9 62 f6 ff ff       	jmp    80105095 <alltraps>

80105a33 <vector149>:
.globl vector149
vector149:
  pushl $0
80105a33:	6a 00                	push   $0x0
  pushl $149
80105a35:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105a3a:	e9 56 f6 ff ff       	jmp    80105095 <alltraps>

80105a3f <vector150>:
.globl vector150
vector150:
  pushl $0
80105a3f:	6a 00                	push   $0x0
  pushl $150
80105a41:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105a46:	e9 4a f6 ff ff       	jmp    80105095 <alltraps>

80105a4b <vector151>:
.globl vector151
vector151:
  pushl $0
80105a4b:	6a 00                	push   $0x0
  pushl $151
80105a4d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105a52:	e9 3e f6 ff ff       	jmp    80105095 <alltraps>

80105a57 <vector152>:
.globl vector152
vector152:
  pushl $0
80105a57:	6a 00                	push   $0x0
  pushl $152
80105a59:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105a5e:	e9 32 f6 ff ff       	jmp    80105095 <alltraps>

80105a63 <vector153>:
.globl vector153
vector153:
  pushl $0
80105a63:	6a 00                	push   $0x0
  pushl $153
80105a65:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105a6a:	e9 26 f6 ff ff       	jmp    80105095 <alltraps>

80105a6f <vector154>:
.globl vector154
vector154:
  pushl $0
80105a6f:	6a 00                	push   $0x0
  pushl $154
80105a71:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105a76:	e9 1a f6 ff ff       	jmp    80105095 <alltraps>

80105a7b <vector155>:
.globl vector155
vector155:
  pushl $0
80105a7b:	6a 00                	push   $0x0
  pushl $155
80105a7d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105a82:	e9 0e f6 ff ff       	jmp    80105095 <alltraps>

80105a87 <vector156>:
.globl vector156
vector156:
  pushl $0
80105a87:	6a 00                	push   $0x0
  pushl $156
80105a89:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105a8e:	e9 02 f6 ff ff       	jmp    80105095 <alltraps>

80105a93 <vector157>:
.globl vector157
vector157:
  pushl $0
80105a93:	6a 00                	push   $0x0
  pushl $157
80105a95:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105a9a:	e9 f6 f5 ff ff       	jmp    80105095 <alltraps>

80105a9f <vector158>:
.globl vector158
vector158:
  pushl $0
80105a9f:	6a 00                	push   $0x0
  pushl $158
80105aa1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105aa6:	e9 ea f5 ff ff       	jmp    80105095 <alltraps>

80105aab <vector159>:
.globl vector159
vector159:
  pushl $0
80105aab:	6a 00                	push   $0x0
  pushl $159
80105aad:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105ab2:	e9 de f5 ff ff       	jmp    80105095 <alltraps>

80105ab7 <vector160>:
.globl vector160
vector160:
  pushl $0
80105ab7:	6a 00                	push   $0x0
  pushl $160
80105ab9:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105abe:	e9 d2 f5 ff ff       	jmp    80105095 <alltraps>

80105ac3 <vector161>:
.globl vector161
vector161:
  pushl $0
80105ac3:	6a 00                	push   $0x0
  pushl $161
80105ac5:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105aca:	e9 c6 f5 ff ff       	jmp    80105095 <alltraps>

80105acf <vector162>:
.globl vector162
vector162:
  pushl $0
80105acf:	6a 00                	push   $0x0
  pushl $162
80105ad1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105ad6:	e9 ba f5 ff ff       	jmp    80105095 <alltraps>

80105adb <vector163>:
.globl vector163
vector163:
  pushl $0
80105adb:	6a 00                	push   $0x0
  pushl $163
80105add:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105ae2:	e9 ae f5 ff ff       	jmp    80105095 <alltraps>

80105ae7 <vector164>:
.globl vector164
vector164:
  pushl $0
80105ae7:	6a 00                	push   $0x0
  pushl $164
80105ae9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105aee:	e9 a2 f5 ff ff       	jmp    80105095 <alltraps>

80105af3 <vector165>:
.globl vector165
vector165:
  pushl $0
80105af3:	6a 00                	push   $0x0
  pushl $165
80105af5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105afa:	e9 96 f5 ff ff       	jmp    80105095 <alltraps>

80105aff <vector166>:
.globl vector166
vector166:
  pushl $0
80105aff:	6a 00                	push   $0x0
  pushl $166
80105b01:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105b06:	e9 8a f5 ff ff       	jmp    80105095 <alltraps>

80105b0b <vector167>:
.globl vector167
vector167:
  pushl $0
80105b0b:	6a 00                	push   $0x0
  pushl $167
80105b0d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105b12:	e9 7e f5 ff ff       	jmp    80105095 <alltraps>

80105b17 <vector168>:
.globl vector168
vector168:
  pushl $0
80105b17:	6a 00                	push   $0x0
  pushl $168
80105b19:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105b1e:	e9 72 f5 ff ff       	jmp    80105095 <alltraps>

80105b23 <vector169>:
.globl vector169
vector169:
  pushl $0
80105b23:	6a 00                	push   $0x0
  pushl $169
80105b25:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105b2a:	e9 66 f5 ff ff       	jmp    80105095 <alltraps>

80105b2f <vector170>:
.globl vector170
vector170:
  pushl $0
80105b2f:	6a 00                	push   $0x0
  pushl $170
80105b31:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105b36:	e9 5a f5 ff ff       	jmp    80105095 <alltraps>

80105b3b <vector171>:
.globl vector171
vector171:
  pushl $0
80105b3b:	6a 00                	push   $0x0
  pushl $171
80105b3d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105b42:	e9 4e f5 ff ff       	jmp    80105095 <alltraps>

80105b47 <vector172>:
.globl vector172
vector172:
  pushl $0
80105b47:	6a 00                	push   $0x0
  pushl $172
80105b49:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105b4e:	e9 42 f5 ff ff       	jmp    80105095 <alltraps>

80105b53 <vector173>:
.globl vector173
vector173:
  pushl $0
80105b53:	6a 00                	push   $0x0
  pushl $173
80105b55:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105b5a:	e9 36 f5 ff ff       	jmp    80105095 <alltraps>

80105b5f <vector174>:
.globl vector174
vector174:
  pushl $0
80105b5f:	6a 00                	push   $0x0
  pushl $174
80105b61:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105b66:	e9 2a f5 ff ff       	jmp    80105095 <alltraps>

80105b6b <vector175>:
.globl vector175
vector175:
  pushl $0
80105b6b:	6a 00                	push   $0x0
  pushl $175
80105b6d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105b72:	e9 1e f5 ff ff       	jmp    80105095 <alltraps>

80105b77 <vector176>:
.globl vector176
vector176:
  pushl $0
80105b77:	6a 00                	push   $0x0
  pushl $176
80105b79:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105b7e:	e9 12 f5 ff ff       	jmp    80105095 <alltraps>

80105b83 <vector177>:
.globl vector177
vector177:
  pushl $0
80105b83:	6a 00                	push   $0x0
  pushl $177
80105b85:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105b8a:	e9 06 f5 ff ff       	jmp    80105095 <alltraps>

80105b8f <vector178>:
.globl vector178
vector178:
  pushl $0
80105b8f:	6a 00                	push   $0x0
  pushl $178
80105b91:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105b96:	e9 fa f4 ff ff       	jmp    80105095 <alltraps>

80105b9b <vector179>:
.globl vector179
vector179:
  pushl $0
80105b9b:	6a 00                	push   $0x0
  pushl $179
80105b9d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105ba2:	e9 ee f4 ff ff       	jmp    80105095 <alltraps>

80105ba7 <vector180>:
.globl vector180
vector180:
  pushl $0
80105ba7:	6a 00                	push   $0x0
  pushl $180
80105ba9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105bae:	e9 e2 f4 ff ff       	jmp    80105095 <alltraps>

80105bb3 <vector181>:
.globl vector181
vector181:
  pushl $0
80105bb3:	6a 00                	push   $0x0
  pushl $181
80105bb5:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105bba:	e9 d6 f4 ff ff       	jmp    80105095 <alltraps>

80105bbf <vector182>:
.globl vector182
vector182:
  pushl $0
80105bbf:	6a 00                	push   $0x0
  pushl $182
80105bc1:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105bc6:	e9 ca f4 ff ff       	jmp    80105095 <alltraps>

80105bcb <vector183>:
.globl vector183
vector183:
  pushl $0
80105bcb:	6a 00                	push   $0x0
  pushl $183
80105bcd:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105bd2:	e9 be f4 ff ff       	jmp    80105095 <alltraps>

80105bd7 <vector184>:
.globl vector184
vector184:
  pushl $0
80105bd7:	6a 00                	push   $0x0
  pushl $184
80105bd9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105bde:	e9 b2 f4 ff ff       	jmp    80105095 <alltraps>

80105be3 <vector185>:
.globl vector185
vector185:
  pushl $0
80105be3:	6a 00                	push   $0x0
  pushl $185
80105be5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105bea:	e9 a6 f4 ff ff       	jmp    80105095 <alltraps>

80105bef <vector186>:
.globl vector186
vector186:
  pushl $0
80105bef:	6a 00                	push   $0x0
  pushl $186
80105bf1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105bf6:	e9 9a f4 ff ff       	jmp    80105095 <alltraps>

80105bfb <vector187>:
.globl vector187
vector187:
  pushl $0
80105bfb:	6a 00                	push   $0x0
  pushl $187
80105bfd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105c02:	e9 8e f4 ff ff       	jmp    80105095 <alltraps>

80105c07 <vector188>:
.globl vector188
vector188:
  pushl $0
80105c07:	6a 00                	push   $0x0
  pushl $188
80105c09:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105c0e:	e9 82 f4 ff ff       	jmp    80105095 <alltraps>

80105c13 <vector189>:
.globl vector189
vector189:
  pushl $0
80105c13:	6a 00                	push   $0x0
  pushl $189
80105c15:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105c1a:	e9 76 f4 ff ff       	jmp    80105095 <alltraps>

80105c1f <vector190>:
.globl vector190
vector190:
  pushl $0
80105c1f:	6a 00                	push   $0x0
  pushl $190
80105c21:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105c26:	e9 6a f4 ff ff       	jmp    80105095 <alltraps>

80105c2b <vector191>:
.globl vector191
vector191:
  pushl $0
80105c2b:	6a 00                	push   $0x0
  pushl $191
80105c2d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105c32:	e9 5e f4 ff ff       	jmp    80105095 <alltraps>

80105c37 <vector192>:
.globl vector192
vector192:
  pushl $0
80105c37:	6a 00                	push   $0x0
  pushl $192
80105c39:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105c3e:	e9 52 f4 ff ff       	jmp    80105095 <alltraps>

80105c43 <vector193>:
.globl vector193
vector193:
  pushl $0
80105c43:	6a 00                	push   $0x0
  pushl $193
80105c45:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105c4a:	e9 46 f4 ff ff       	jmp    80105095 <alltraps>

80105c4f <vector194>:
.globl vector194
vector194:
  pushl $0
80105c4f:	6a 00                	push   $0x0
  pushl $194
80105c51:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105c56:	e9 3a f4 ff ff       	jmp    80105095 <alltraps>

80105c5b <vector195>:
.globl vector195
vector195:
  pushl $0
80105c5b:	6a 00                	push   $0x0
  pushl $195
80105c5d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105c62:	e9 2e f4 ff ff       	jmp    80105095 <alltraps>

80105c67 <vector196>:
.globl vector196
vector196:
  pushl $0
80105c67:	6a 00                	push   $0x0
  pushl $196
80105c69:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105c6e:	e9 22 f4 ff ff       	jmp    80105095 <alltraps>

80105c73 <vector197>:
.globl vector197
vector197:
  pushl $0
80105c73:	6a 00                	push   $0x0
  pushl $197
80105c75:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105c7a:	e9 16 f4 ff ff       	jmp    80105095 <alltraps>

80105c7f <vector198>:
.globl vector198
vector198:
  pushl $0
80105c7f:	6a 00                	push   $0x0
  pushl $198
80105c81:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105c86:	e9 0a f4 ff ff       	jmp    80105095 <alltraps>

80105c8b <vector199>:
.globl vector199
vector199:
  pushl $0
80105c8b:	6a 00                	push   $0x0
  pushl $199
80105c8d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105c92:	e9 fe f3 ff ff       	jmp    80105095 <alltraps>

80105c97 <vector200>:
.globl vector200
vector200:
  pushl $0
80105c97:	6a 00                	push   $0x0
  pushl $200
80105c99:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105c9e:	e9 f2 f3 ff ff       	jmp    80105095 <alltraps>

80105ca3 <vector201>:
.globl vector201
vector201:
  pushl $0
80105ca3:	6a 00                	push   $0x0
  pushl $201
80105ca5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105caa:	e9 e6 f3 ff ff       	jmp    80105095 <alltraps>

80105caf <vector202>:
.globl vector202
vector202:
  pushl $0
80105caf:	6a 00                	push   $0x0
  pushl $202
80105cb1:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105cb6:	e9 da f3 ff ff       	jmp    80105095 <alltraps>

80105cbb <vector203>:
.globl vector203
vector203:
  pushl $0
80105cbb:	6a 00                	push   $0x0
  pushl $203
80105cbd:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105cc2:	e9 ce f3 ff ff       	jmp    80105095 <alltraps>

80105cc7 <vector204>:
.globl vector204
vector204:
  pushl $0
80105cc7:	6a 00                	push   $0x0
  pushl $204
80105cc9:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105cce:	e9 c2 f3 ff ff       	jmp    80105095 <alltraps>

80105cd3 <vector205>:
.globl vector205
vector205:
  pushl $0
80105cd3:	6a 00                	push   $0x0
  pushl $205
80105cd5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105cda:	e9 b6 f3 ff ff       	jmp    80105095 <alltraps>

80105cdf <vector206>:
.globl vector206
vector206:
  pushl $0
80105cdf:	6a 00                	push   $0x0
  pushl $206
80105ce1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105ce6:	e9 aa f3 ff ff       	jmp    80105095 <alltraps>

80105ceb <vector207>:
.globl vector207
vector207:
  pushl $0
80105ceb:	6a 00                	push   $0x0
  pushl $207
80105ced:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105cf2:	e9 9e f3 ff ff       	jmp    80105095 <alltraps>

80105cf7 <vector208>:
.globl vector208
vector208:
  pushl $0
80105cf7:	6a 00                	push   $0x0
  pushl $208
80105cf9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105cfe:	e9 92 f3 ff ff       	jmp    80105095 <alltraps>

80105d03 <vector209>:
.globl vector209
vector209:
  pushl $0
80105d03:	6a 00                	push   $0x0
  pushl $209
80105d05:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105d0a:	e9 86 f3 ff ff       	jmp    80105095 <alltraps>

80105d0f <vector210>:
.globl vector210
vector210:
  pushl $0
80105d0f:	6a 00                	push   $0x0
  pushl $210
80105d11:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105d16:	e9 7a f3 ff ff       	jmp    80105095 <alltraps>

80105d1b <vector211>:
.globl vector211
vector211:
  pushl $0
80105d1b:	6a 00                	push   $0x0
  pushl $211
80105d1d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105d22:	e9 6e f3 ff ff       	jmp    80105095 <alltraps>

80105d27 <vector212>:
.globl vector212
vector212:
  pushl $0
80105d27:	6a 00                	push   $0x0
  pushl $212
80105d29:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105d2e:	e9 62 f3 ff ff       	jmp    80105095 <alltraps>

80105d33 <vector213>:
.globl vector213
vector213:
  pushl $0
80105d33:	6a 00                	push   $0x0
  pushl $213
80105d35:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105d3a:	e9 56 f3 ff ff       	jmp    80105095 <alltraps>

80105d3f <vector214>:
.globl vector214
vector214:
  pushl $0
80105d3f:	6a 00                	push   $0x0
  pushl $214
80105d41:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105d46:	e9 4a f3 ff ff       	jmp    80105095 <alltraps>

80105d4b <vector215>:
.globl vector215
vector215:
  pushl $0
80105d4b:	6a 00                	push   $0x0
  pushl $215
80105d4d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105d52:	e9 3e f3 ff ff       	jmp    80105095 <alltraps>

80105d57 <vector216>:
.globl vector216
vector216:
  pushl $0
80105d57:	6a 00                	push   $0x0
  pushl $216
80105d59:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105d5e:	e9 32 f3 ff ff       	jmp    80105095 <alltraps>

80105d63 <vector217>:
.globl vector217
vector217:
  pushl $0
80105d63:	6a 00                	push   $0x0
  pushl $217
80105d65:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105d6a:	e9 26 f3 ff ff       	jmp    80105095 <alltraps>

80105d6f <vector218>:
.globl vector218
vector218:
  pushl $0
80105d6f:	6a 00                	push   $0x0
  pushl $218
80105d71:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105d76:	e9 1a f3 ff ff       	jmp    80105095 <alltraps>

80105d7b <vector219>:
.globl vector219
vector219:
  pushl $0
80105d7b:	6a 00                	push   $0x0
  pushl $219
80105d7d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105d82:	e9 0e f3 ff ff       	jmp    80105095 <alltraps>

80105d87 <vector220>:
.globl vector220
vector220:
  pushl $0
80105d87:	6a 00                	push   $0x0
  pushl $220
80105d89:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105d8e:	e9 02 f3 ff ff       	jmp    80105095 <alltraps>

80105d93 <vector221>:
.globl vector221
vector221:
  pushl $0
80105d93:	6a 00                	push   $0x0
  pushl $221
80105d95:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105d9a:	e9 f6 f2 ff ff       	jmp    80105095 <alltraps>

80105d9f <vector222>:
.globl vector222
vector222:
  pushl $0
80105d9f:	6a 00                	push   $0x0
  pushl $222
80105da1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105da6:	e9 ea f2 ff ff       	jmp    80105095 <alltraps>

80105dab <vector223>:
.globl vector223
vector223:
  pushl $0
80105dab:	6a 00                	push   $0x0
  pushl $223
80105dad:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105db2:	e9 de f2 ff ff       	jmp    80105095 <alltraps>

80105db7 <vector224>:
.globl vector224
vector224:
  pushl $0
80105db7:	6a 00                	push   $0x0
  pushl $224
80105db9:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105dbe:	e9 d2 f2 ff ff       	jmp    80105095 <alltraps>

80105dc3 <vector225>:
.globl vector225
vector225:
  pushl $0
80105dc3:	6a 00                	push   $0x0
  pushl $225
80105dc5:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105dca:	e9 c6 f2 ff ff       	jmp    80105095 <alltraps>

80105dcf <vector226>:
.globl vector226
vector226:
  pushl $0
80105dcf:	6a 00                	push   $0x0
  pushl $226
80105dd1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105dd6:	e9 ba f2 ff ff       	jmp    80105095 <alltraps>

80105ddb <vector227>:
.globl vector227
vector227:
  pushl $0
80105ddb:	6a 00                	push   $0x0
  pushl $227
80105ddd:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105de2:	e9 ae f2 ff ff       	jmp    80105095 <alltraps>

80105de7 <vector228>:
.globl vector228
vector228:
  pushl $0
80105de7:	6a 00                	push   $0x0
  pushl $228
80105de9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105dee:	e9 a2 f2 ff ff       	jmp    80105095 <alltraps>

80105df3 <vector229>:
.globl vector229
vector229:
  pushl $0
80105df3:	6a 00                	push   $0x0
  pushl $229
80105df5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105dfa:	e9 96 f2 ff ff       	jmp    80105095 <alltraps>

80105dff <vector230>:
.globl vector230
vector230:
  pushl $0
80105dff:	6a 00                	push   $0x0
  pushl $230
80105e01:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105e06:	e9 8a f2 ff ff       	jmp    80105095 <alltraps>

80105e0b <vector231>:
.globl vector231
vector231:
  pushl $0
80105e0b:	6a 00                	push   $0x0
  pushl $231
80105e0d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105e12:	e9 7e f2 ff ff       	jmp    80105095 <alltraps>

80105e17 <vector232>:
.globl vector232
vector232:
  pushl $0
80105e17:	6a 00                	push   $0x0
  pushl $232
80105e19:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105e1e:	e9 72 f2 ff ff       	jmp    80105095 <alltraps>

80105e23 <vector233>:
.globl vector233
vector233:
  pushl $0
80105e23:	6a 00                	push   $0x0
  pushl $233
80105e25:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105e2a:	e9 66 f2 ff ff       	jmp    80105095 <alltraps>

80105e2f <vector234>:
.globl vector234
vector234:
  pushl $0
80105e2f:	6a 00                	push   $0x0
  pushl $234
80105e31:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105e36:	e9 5a f2 ff ff       	jmp    80105095 <alltraps>

80105e3b <vector235>:
.globl vector235
vector235:
  pushl $0
80105e3b:	6a 00                	push   $0x0
  pushl $235
80105e3d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105e42:	e9 4e f2 ff ff       	jmp    80105095 <alltraps>

80105e47 <vector236>:
.globl vector236
vector236:
  pushl $0
80105e47:	6a 00                	push   $0x0
  pushl $236
80105e49:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105e4e:	e9 42 f2 ff ff       	jmp    80105095 <alltraps>

80105e53 <vector237>:
.globl vector237
vector237:
  pushl $0
80105e53:	6a 00                	push   $0x0
  pushl $237
80105e55:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105e5a:	e9 36 f2 ff ff       	jmp    80105095 <alltraps>

80105e5f <vector238>:
.globl vector238
vector238:
  pushl $0
80105e5f:	6a 00                	push   $0x0
  pushl $238
80105e61:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105e66:	e9 2a f2 ff ff       	jmp    80105095 <alltraps>

80105e6b <vector239>:
.globl vector239
vector239:
  pushl $0
80105e6b:	6a 00                	push   $0x0
  pushl $239
80105e6d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105e72:	e9 1e f2 ff ff       	jmp    80105095 <alltraps>

80105e77 <vector240>:
.globl vector240
vector240:
  pushl $0
80105e77:	6a 00                	push   $0x0
  pushl $240
80105e79:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105e7e:	e9 12 f2 ff ff       	jmp    80105095 <alltraps>

80105e83 <vector241>:
.globl vector241
vector241:
  pushl $0
80105e83:	6a 00                	push   $0x0
  pushl $241
80105e85:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105e8a:	e9 06 f2 ff ff       	jmp    80105095 <alltraps>

80105e8f <vector242>:
.globl vector242
vector242:
  pushl $0
80105e8f:	6a 00                	push   $0x0
  pushl $242
80105e91:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105e96:	e9 fa f1 ff ff       	jmp    80105095 <alltraps>

80105e9b <vector243>:
.globl vector243
vector243:
  pushl $0
80105e9b:	6a 00                	push   $0x0
  pushl $243
80105e9d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105ea2:	e9 ee f1 ff ff       	jmp    80105095 <alltraps>

80105ea7 <vector244>:
.globl vector244
vector244:
  pushl $0
80105ea7:	6a 00                	push   $0x0
  pushl $244
80105ea9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105eae:	e9 e2 f1 ff ff       	jmp    80105095 <alltraps>

80105eb3 <vector245>:
.globl vector245
vector245:
  pushl $0
80105eb3:	6a 00                	push   $0x0
  pushl $245
80105eb5:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105eba:	e9 d6 f1 ff ff       	jmp    80105095 <alltraps>

80105ebf <vector246>:
.globl vector246
vector246:
  pushl $0
80105ebf:	6a 00                	push   $0x0
  pushl $246
80105ec1:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105ec6:	e9 ca f1 ff ff       	jmp    80105095 <alltraps>

80105ecb <vector247>:
.globl vector247
vector247:
  pushl $0
80105ecb:	6a 00                	push   $0x0
  pushl $247
80105ecd:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105ed2:	e9 be f1 ff ff       	jmp    80105095 <alltraps>

80105ed7 <vector248>:
.globl vector248
vector248:
  pushl $0
80105ed7:	6a 00                	push   $0x0
  pushl $248
80105ed9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105ede:	e9 b2 f1 ff ff       	jmp    80105095 <alltraps>

80105ee3 <vector249>:
.globl vector249
vector249:
  pushl $0
80105ee3:	6a 00                	push   $0x0
  pushl $249
80105ee5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105eea:	e9 a6 f1 ff ff       	jmp    80105095 <alltraps>

80105eef <vector250>:
.globl vector250
vector250:
  pushl $0
80105eef:	6a 00                	push   $0x0
  pushl $250
80105ef1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105ef6:	e9 9a f1 ff ff       	jmp    80105095 <alltraps>

80105efb <vector251>:
.globl vector251
vector251:
  pushl $0
80105efb:	6a 00                	push   $0x0
  pushl $251
80105efd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105f02:	e9 8e f1 ff ff       	jmp    80105095 <alltraps>

80105f07 <vector252>:
.globl vector252
vector252:
  pushl $0
80105f07:	6a 00                	push   $0x0
  pushl $252
80105f09:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105f0e:	e9 82 f1 ff ff       	jmp    80105095 <alltraps>

80105f13 <vector253>:
.globl vector253
vector253:
  pushl $0
80105f13:	6a 00                	push   $0x0
  pushl $253
80105f15:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105f1a:	e9 76 f1 ff ff       	jmp    80105095 <alltraps>

80105f1f <vector254>:
.globl vector254
vector254:
  pushl $0
80105f1f:	6a 00                	push   $0x0
  pushl $254
80105f21:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105f26:	e9 6a f1 ff ff       	jmp    80105095 <alltraps>

80105f2b <vector255>:
.globl vector255
vector255:
  pushl $0
80105f2b:	6a 00                	push   $0x0
  pushl $255
80105f2d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105f32:	e9 5e f1 ff ff       	jmp    80105095 <alltraps>
80105f37:	90                   	nop

80105f38 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105f38:	55                   	push   %ebp
80105f39:	89 e5                	mov    %esp,%ebp
80105f3b:	57                   	push   %edi
80105f3c:	56                   	push   %esi
80105f3d:	53                   	push   %ebx
80105f3e:	83 ec 0c             	sub    $0xc,%esp
80105f41:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105f43:	c1 ea 16             	shr    $0x16,%edx
80105f46:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105f49:	8b 1f                	mov    (%edi),%ebx
80105f4b:	f6 c3 01             	test   $0x1,%bl
80105f4e:	74 20                	je     80105f70 <walkpgdir+0x38>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105f50:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105f56:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105f5c:	89 f0                	mov    %esi,%eax
80105f5e:	c1 e8 0a             	shr    $0xa,%eax
80105f61:	25 fc 0f 00 00       	and    $0xffc,%eax
80105f66:	01 d8                	add    %ebx,%eax
}
80105f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f6b:	5b                   	pop    %ebx
80105f6c:	5e                   	pop    %esi
80105f6d:	5f                   	pop    %edi
80105f6e:	5d                   	pop    %ebp
80105f6f:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105f70:	85 c9                	test   %ecx,%ecx
80105f72:	74 2c                	je     80105fa0 <walkpgdir+0x68>
80105f74:	e8 bb c2 ff ff       	call   80102234 <kalloc>
80105f79:	89 c3                	mov    %eax,%ebx
80105f7b:	85 c0                	test   %eax,%eax
80105f7d:	74 21                	je     80105fa0 <walkpgdir+0x68>
    memset(pgtab, 0, PGSIZE);
80105f7f:	50                   	push   %eax
80105f80:	68 00 10 00 00       	push   $0x1000
80105f85:	6a 00                	push   $0x0
80105f87:	53                   	push   %ebx
80105f88:	e8 9f e1 ff ff       	call   8010412c <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105f8d:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105f93:	83 c8 07             	or     $0x7,%eax
80105f96:	89 07                	mov    %eax,(%edi)
80105f98:	83 c4 10             	add    $0x10,%esp
80105f9b:	eb bf                	jmp    80105f5c <walkpgdir+0x24>
80105f9d:	8d 76 00             	lea    0x0(%esi),%esi
      return 0;
80105fa0:	31 c0                	xor    %eax,%eax
}
80105fa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105fa5:	5b                   	pop    %ebx
80105fa6:	5e                   	pop    %esi
80105fa7:	5f                   	pop    %edi
80105fa8:	5d                   	pop    %ebp
80105fa9:	c3                   	ret    
80105faa:	66 90                	xchg   %ax,%ax

80105fac <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105fac:	55                   	push   %ebp
80105fad:	89 e5                	mov    %esp,%ebp
80105faf:	57                   	push   %edi
80105fb0:	56                   	push   %esi
80105fb1:	53                   	push   %ebx
80105fb2:	83 ec 1c             	sub    $0x1c,%esp
80105fb5:	89 c7                	mov    %eax,%edi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105fb7:	89 d6                	mov    %edx,%esi
80105fb9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105fbf:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
80105fc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80105fc8:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80105fce:	29 f0                	sub    %esi,%eax
80105fd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105fd3:	eb 1b                	jmp    80105ff0 <mappages+0x44>
80105fd5:	8d 76 00             	lea    0x0(%esi),%esi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
80105fd8:	f6 00 01             	testb  $0x1,(%eax)
80105fdb:	75 45                	jne    80106022 <mappages+0x76>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105fdd:	0b 5d 0c             	or     0xc(%ebp),%ebx
80105fe0:	83 cb 01             	or     $0x1,%ebx
80105fe3:	89 18                	mov    %ebx,(%eax)
    if(a == last)
80105fe5:	3b 75 e0             	cmp    -0x20(%ebp),%esi
80105fe8:	74 2e                	je     80106018 <mappages+0x6c>
      break;
    a += PGSIZE;
80105fea:	81 c6 00 10 00 00    	add    $0x1000,%esi
  for(;;){
80105ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ff3:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105ff6:	b9 01 00 00 00       	mov    $0x1,%ecx
80105ffb:	89 f2                	mov    %esi,%edx
80105ffd:	89 f8                	mov    %edi,%eax
80105fff:	e8 34 ff ff ff       	call   80105f38 <walkpgdir>
80106004:	85 c0                	test   %eax,%eax
80106006:	75 d0                	jne    80105fd8 <mappages+0x2c>
      return -1;
80106008:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    pa += PGSIZE;
  }
  return 0;
}
8010600d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106010:	5b                   	pop    %ebx
80106011:	5e                   	pop    %esi
80106012:	5f                   	pop    %edi
80106013:	5d                   	pop    %ebp
80106014:	c3                   	ret    
80106015:	8d 76 00             	lea    0x0(%esi),%esi
  return 0;
80106018:	31 c0                	xor    %eax,%eax
}
8010601a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010601d:	5b                   	pop    %ebx
8010601e:	5e                   	pop    %esi
8010601f:	5f                   	pop    %edi
80106020:	5d                   	pop    %ebp
80106021:	c3                   	ret    
      panic("remap");
80106022:	83 ec 0c             	sub    $0xc,%esp
80106025:	68 6c 70 10 80       	push   $0x8010706c
8010602a:	e8 11 a3 ff ff       	call   80100340 <panic>
8010602f:	90                   	nop

80106030 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106030:	55                   	push   %ebp
80106031:	89 e5                	mov    %esp,%ebp
80106033:	57                   	push   %edi
80106034:	56                   	push   %esi
80106035:	53                   	push   %ebx
80106036:	83 ec 1c             	sub    $0x1c,%esp
80106039:	89 c6                	mov    %eax,%esi
8010603b:	89 d3                	mov    %edx,%ebx
8010603d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80106040:	8d 91 ff 0f 00 00    	lea    0xfff(%ecx),%edx
80106046:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  for(; a  < oldsz; a += PGSIZE){
8010604c:	39 da                	cmp    %ebx,%edx
8010604e:	73 53                	jae    801060a3 <deallocuvm.part.0+0x73>
80106050:	89 d7                	mov    %edx,%edi
80106052:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80106055:	eb 0c                	jmp    80106063 <deallocuvm.part.0+0x33>
80106057:	90                   	nop
80106058:	81 c7 00 10 00 00    	add    $0x1000,%edi
8010605e:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80106061:	76 40                	jbe    801060a3 <deallocuvm.part.0+0x73>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106063:	31 c9                	xor    %ecx,%ecx
80106065:	89 fa                	mov    %edi,%edx
80106067:	89 f0                	mov    %esi,%eax
80106069:	e8 ca fe ff ff       	call   80105f38 <walkpgdir>
8010606e:	89 c3                	mov    %eax,%ebx
    if(!pte)
80106070:	85 c0                	test   %eax,%eax
80106072:	74 3c                	je     801060b0 <deallocuvm.part.0+0x80>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
80106074:	8b 00                	mov    (%eax),%eax
80106076:	a8 01                	test   $0x1,%al
80106078:	74 de                	je     80106058 <deallocuvm.part.0+0x28>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010607a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010607f:	74 3f                	je     801060c0 <deallocuvm.part.0+0x90>
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106081:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
80106084:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106089:	50                   	push   %eax
8010608a:	e8 15 c0 ff ff       	call   801020a4 <kfree>
      *pte = 0;
8010608f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80106095:	81 c7 00 10 00 00    	add    $0x1000,%edi
8010609b:	83 c4 10             	add    $0x10,%esp
  for(; a  < oldsz; a += PGSIZE){
8010609e:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
801060a1:	77 c0                	ja     80106063 <deallocuvm.part.0+0x33>
    }
  }
  return newsz;
}
801060a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801060a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060a9:	5b                   	pop    %ebx
801060aa:	5e                   	pop    %esi
801060ab:	5f                   	pop    %edi
801060ac:	5d                   	pop    %ebp
801060ad:	c3                   	ret    
801060ae:	66 90                	xchg   %ax,%ax
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801060b0:	89 fa                	mov    %edi,%edx
801060b2:	81 e2 00 00 c0 ff    	and    $0xffc00000,%edx
801060b8:	8d ba 00 00 40 00    	lea    0x400000(%edx),%edi
801060be:	eb 9e                	jmp    8010605e <deallocuvm.part.0+0x2e>
        panic("kfree");
801060c0:	83 ec 0c             	sub    $0xc,%esp
801060c3:	68 06 6a 10 80       	push   $0x80106a06
801060c8:	e8 73 a2 ff ff       	call   80100340 <panic>
801060cd:	8d 76 00             	lea    0x0(%esi),%esi

801060d0 <seginit>:
{
801060d0:	55                   	push   %ebp
801060d1:	89 e5                	mov    %esp,%ebp
801060d3:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
801060d6:	e8 51 d2 ff ff       	call   8010332c <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801060db:	8d 14 80             	lea    (%eax,%eax,4),%edx
801060de:	01 d2                	add    %edx,%edx
801060e0:	01 d0                	add    %edx,%eax
801060e2:	c1 e0 04             	shl    $0x4,%eax
801060e5:	c7 80 d8 31 11 80 ff 	movl   $0xffff,-0x7feece28(%eax)
801060ec:	ff 00 00 
801060ef:	c7 80 dc 31 11 80 00 	movl   $0xcf9a00,-0x7feece24(%eax)
801060f6:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801060f9:	c7 80 e0 31 11 80 ff 	movl   $0xffff,-0x7feece20(%eax)
80106100:	ff 00 00 
80106103:	c7 80 e4 31 11 80 00 	movl   $0xcf9200,-0x7feece1c(%eax)
8010610a:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010610d:	c7 80 e8 31 11 80 ff 	movl   $0xffff,-0x7feece18(%eax)
80106114:	ff 00 00 
80106117:	c7 80 ec 31 11 80 00 	movl   $0xcffa00,-0x7feece14(%eax)
8010611e:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106121:	c7 80 f0 31 11 80 ff 	movl   $0xffff,-0x7feece10(%eax)
80106128:	ff 00 00 
8010612b:	c7 80 f4 31 11 80 00 	movl   $0xcff200,-0x7feece0c(%eax)
80106132:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
80106135:	05 d0 31 11 80       	add    $0x801131d0,%eax
static inline void
lgdt(struct segdesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
8010613a:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80106140:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106144:	c1 e8 10             	shr    $0x10,%eax
80106147:	66 89 45 f6          	mov    %ax,-0xa(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010614b:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010614e:	0f 01 10             	lgdtl  (%eax)
}
80106151:	c9                   	leave  
80106152:	c3                   	ret    
80106153:	90                   	nop

80106154 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106154:	a1 84 5f 11 80       	mov    0x80115f84,%eax
80106159:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010615e:	0f 22 d8             	mov    %eax,%cr3
}
80106161:	c3                   	ret    
80106162:	66 90                	xchg   %ax,%ax

80106164 <switchuvm>:
{
80106164:	55                   	push   %ebp
80106165:	89 e5                	mov    %esp,%ebp
80106167:	57                   	push   %edi
80106168:	56                   	push   %esi
80106169:	53                   	push   %ebx
8010616a:	83 ec 1c             	sub    $0x1c,%esp
8010616d:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106170:	85 f6                	test   %esi,%esi
80106172:	0f 84 bf 00 00 00    	je     80106237 <switchuvm+0xd3>
  if(p->kstack == 0)
80106178:	8b 56 08             	mov    0x8(%esi),%edx
8010617b:	85 d2                	test   %edx,%edx
8010617d:	0f 84 ce 00 00 00    	je     80106251 <switchuvm+0xed>
  if(p->pgdir == 0)
80106183:	8b 46 04             	mov    0x4(%esi),%eax
80106186:	85 c0                	test   %eax,%eax
80106188:	0f 84 b6 00 00 00    	je     80106244 <switchuvm+0xe0>
  pushcli();
8010618e:	e8 dd dd ff ff       	call   80103f70 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106193:	e8 30 d1 ff ff       	call   801032c8 <mycpu>
80106198:	89 c3                	mov    %eax,%ebx
8010619a:	e8 29 d1 ff ff       	call   801032c8 <mycpu>
8010619f:	89 c7                	mov    %eax,%edi
801061a1:	e8 22 d1 ff ff       	call   801032c8 <mycpu>
801061a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801061a9:	e8 1a d1 ff ff       	call   801032c8 <mycpu>
801061ae:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801061b5:	67 00 
801061b7:	83 c7 08             	add    $0x8,%edi
801061ba:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801061c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801061c4:	83 c1 08             	add    $0x8,%ecx
801061c7:	c1 e9 10             	shr    $0x10,%ecx
801061ca:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801061d0:	66 c7 83 9d 00 00 00 	movw   $0x4099,0x9d(%ebx)
801061d7:	99 40 
801061d9:	83 c0 08             	add    $0x8,%eax
801061dc:	c1 e8 18             	shr    $0x18,%eax
801061df:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
  mycpu()->gdt[SEG_TSS].s = 0;
801061e5:	e8 de d0 ff ff       	call   801032c8 <mycpu>
801061ea:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801061f1:	e8 d2 d0 ff ff       	call   801032c8 <mycpu>
801061f6:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801061fc:	8b 5e 08             	mov    0x8(%esi),%ebx
801061ff:	e8 c4 d0 ff ff       	call   801032c8 <mycpu>
80106204:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010620a:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010620d:	e8 b6 d0 ff ff       	call   801032c8 <mycpu>
80106212:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106218:	b8 28 00 00 00       	mov    $0x28,%eax
8010621d:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106220:	8b 46 04             	mov    0x4(%esi),%eax
80106223:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106228:	0f 22 d8             	mov    %eax,%cr3
}
8010622b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010622e:	5b                   	pop    %ebx
8010622f:	5e                   	pop    %esi
80106230:	5f                   	pop    %edi
80106231:	5d                   	pop    %ebp
  popcli();
80106232:	e9 81 dd ff ff       	jmp    80103fb8 <popcli>
    panic("switchuvm: no process");
80106237:	83 ec 0c             	sub    $0xc,%esp
8010623a:	68 72 70 10 80       	push   $0x80107072
8010623f:	e8 fc a0 ff ff       	call   80100340 <panic>
    panic("switchuvm: no pgdir");
80106244:	83 ec 0c             	sub    $0xc,%esp
80106247:	68 9d 70 10 80       	push   $0x8010709d
8010624c:	e8 ef a0 ff ff       	call   80100340 <panic>
    panic("switchuvm: no kstack");
80106251:	83 ec 0c             	sub    $0xc,%esp
80106254:	68 88 70 10 80       	push   $0x80107088
80106259:	e8 e2 a0 ff ff       	call   80100340 <panic>
8010625e:	66 90                	xchg   %ax,%ax

80106260 <inituvm>:
{
80106260:	55                   	push   %ebp
80106261:	89 e5                	mov    %esp,%ebp
80106263:	57                   	push   %edi
80106264:	56                   	push   %esi
80106265:	53                   	push   %ebx
80106266:	83 ec 1c             	sub    $0x1c,%esp
80106269:	8b 45 08             	mov    0x8(%ebp),%eax
8010626c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010626f:	8b 7d 0c             	mov    0xc(%ebp),%edi
80106272:	8b 75 10             	mov    0x10(%ebp),%esi
  if(sz >= PGSIZE)
80106275:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010627b:	77 47                	ja     801062c4 <inituvm+0x64>
  mem = kalloc();
8010627d:	e8 b2 bf ff ff       	call   80102234 <kalloc>
80106282:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106284:	50                   	push   %eax
80106285:	68 00 10 00 00       	push   $0x1000
8010628a:	6a 00                	push   $0x0
8010628c:	53                   	push   %ebx
8010628d:	e8 9a de ff ff       	call   8010412c <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106292:	5a                   	pop    %edx
80106293:	59                   	pop    %ecx
80106294:	6a 06                	push   $0x6
80106296:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010629c:	50                   	push   %eax
8010629d:	b9 00 10 00 00       	mov    $0x1000,%ecx
801062a2:	31 d2                	xor    %edx,%edx
801062a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062a7:	e8 00 fd ff ff       	call   80105fac <mappages>
  memmove(mem, init, sz);
801062ac:	83 c4 10             	add    $0x10,%esp
801062af:	89 75 10             	mov    %esi,0x10(%ebp)
801062b2:	89 7d 0c             	mov    %edi,0xc(%ebp)
801062b5:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801062b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062bb:	5b                   	pop    %ebx
801062bc:	5e                   	pop    %esi
801062bd:	5f                   	pop    %edi
801062be:	5d                   	pop    %ebp
  memmove(mem, init, sz);
801062bf:	e9 ec de ff ff       	jmp    801041b0 <memmove>
    panic("inituvm: more than a page");
801062c4:	83 ec 0c             	sub    $0xc,%esp
801062c7:	68 b1 70 10 80       	push   $0x801070b1
801062cc:	e8 6f a0 ff ff       	call   80100340 <panic>
801062d1:	8d 76 00             	lea    0x0(%esi),%esi

801062d4 <loaduvm>:
{
801062d4:	55                   	push   %ebp
801062d5:	89 e5                	mov    %esp,%ebp
801062d7:	57                   	push   %edi
801062d8:	56                   	push   %esi
801062d9:	53                   	push   %ebx
801062da:	83 ec 1c             	sub    $0x1c,%esp
801062dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801062e0:	8b 75 18             	mov    0x18(%ebp),%esi
  if((uint) addr % PGSIZE != 0)
801062e3:	a9 ff 0f 00 00       	test   $0xfff,%eax
801062e8:	0f 85 94 00 00 00    	jne    80106382 <loaduvm+0xae>
  for(i = 0; i < sz; i += PGSIZE){
801062ee:	85 f6                	test   %esi,%esi
801062f0:	74 6a                	je     8010635c <loaduvm+0x88>
801062f2:	89 f3                	mov    %esi,%ebx
801062f4:	01 f0                	add    %esi,%eax
801062f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801062f9:	8b 45 14             	mov    0x14(%ebp),%eax
801062fc:	01 f0                	add    %esi,%eax
801062fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106301:	eb 2d                	jmp    80106330 <loaduvm+0x5c>
80106303:	90                   	nop
    if(sz - i < PGSIZE)
80106304:	89 df                	mov    %ebx,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106306:	57                   	push   %edi
80106307:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010630a:	29 d9                	sub    %ebx,%ecx
8010630c:	51                   	push   %ecx
8010630d:	05 00 00 00 80       	add    $0x80000000,%eax
80106312:	50                   	push   %eax
80106313:	ff 75 10             	pushl  0x10(%ebp)
80106316:	e8 e5 b4 ff ff       	call   80101800 <readi>
8010631b:	83 c4 10             	add    $0x10,%esp
8010631e:	39 f8                	cmp    %edi,%eax
80106320:	75 46                	jne    80106368 <loaduvm+0x94>
  for(i = 0; i < sz; i += PGSIZE){
80106322:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
80106328:	89 f0                	mov    %esi,%eax
8010632a:	29 d8                	sub    %ebx,%eax
8010632c:	39 c6                	cmp    %eax,%esi
8010632e:	76 2c                	jbe    8010635c <loaduvm+0x88>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106330:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106333:	29 da                	sub    %ebx,%edx
80106335:	31 c9                	xor    %ecx,%ecx
80106337:	8b 45 08             	mov    0x8(%ebp),%eax
8010633a:	e8 f9 fb ff ff       	call   80105f38 <walkpgdir>
8010633f:	85 c0                	test   %eax,%eax
80106341:	74 32                	je     80106375 <loaduvm+0xa1>
    pa = PTE_ADDR(*pte);
80106343:	8b 00                	mov    (%eax),%eax
80106345:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
8010634a:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
80106350:	76 b2                	jbe    80106304 <loaduvm+0x30>
      n = PGSIZE;
80106352:	bf 00 10 00 00       	mov    $0x1000,%edi
80106357:	eb ad                	jmp    80106306 <loaduvm+0x32>
80106359:	8d 76 00             	lea    0x0(%esi),%esi
  return 0;
8010635c:	31 c0                	xor    %eax,%eax
}
8010635e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106361:	5b                   	pop    %ebx
80106362:	5e                   	pop    %esi
80106363:	5f                   	pop    %edi
80106364:	5d                   	pop    %ebp
80106365:	c3                   	ret    
80106366:	66 90                	xchg   %ax,%ax
      return -1;
80106368:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010636d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106370:	5b                   	pop    %ebx
80106371:	5e                   	pop    %esi
80106372:	5f                   	pop    %edi
80106373:	5d                   	pop    %ebp
80106374:	c3                   	ret    
      panic("loaduvm: address should exist");
80106375:	83 ec 0c             	sub    $0xc,%esp
80106378:	68 cb 70 10 80       	push   $0x801070cb
8010637d:	e8 be 9f ff ff       	call   80100340 <panic>
    panic("loaduvm: addr must be page aligned");
80106382:	83 ec 0c             	sub    $0xc,%esp
80106385:	68 6c 71 10 80       	push   $0x8010716c
8010638a:	e8 b1 9f ff ff       	call   80100340 <panic>
8010638f:	90                   	nop

80106390 <allocuvm>:
{
80106390:	55                   	push   %ebp
80106391:	89 e5                	mov    %esp,%ebp
80106393:	57                   	push   %edi
80106394:	56                   	push   %esi
80106395:	53                   	push   %ebx
80106396:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80106399:	8b 7d 10             	mov    0x10(%ebp),%edi
8010639c:	85 ff                	test   %edi,%edi
8010639e:	0f 88 b8 00 00 00    	js     8010645c <allocuvm+0xcc>
  if(newsz < oldsz)
801063a4:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801063a7:	0f 82 9f 00 00 00    	jb     8010644c <allocuvm+0xbc>
  a = PGROUNDUP(oldsz);
801063ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801063b0:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801063b6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
801063bc:	39 75 10             	cmp    %esi,0x10(%ebp)
801063bf:	0f 86 8a 00 00 00    	jbe    8010644f <allocuvm+0xbf>
801063c5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801063c8:	8b 7d 10             	mov    0x10(%ebp),%edi
801063cb:	eb 40                	jmp    8010640d <allocuvm+0x7d>
801063cd:	8d 76 00             	lea    0x0(%esi),%esi
    memset(mem, 0, PGSIZE);
801063d0:	50                   	push   %eax
801063d1:	68 00 10 00 00       	push   $0x1000
801063d6:	6a 00                	push   $0x0
801063d8:	53                   	push   %ebx
801063d9:	e8 4e dd ff ff       	call   8010412c <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801063de:	5a                   	pop    %edx
801063df:	59                   	pop    %ecx
801063e0:	6a 06                	push   $0x6
801063e2:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801063e8:	50                   	push   %eax
801063e9:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063ee:	89 f2                	mov    %esi,%edx
801063f0:	8b 45 08             	mov    0x8(%ebp),%eax
801063f3:	e8 b4 fb ff ff       	call   80105fac <mappages>
801063f8:	83 c4 10             	add    $0x10,%esp
801063fb:	85 c0                	test   %eax,%eax
801063fd:	78 69                	js     80106468 <allocuvm+0xd8>
  for(; a < newsz; a += PGSIZE){
801063ff:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106405:	39 f7                	cmp    %esi,%edi
80106407:	0f 86 9b 00 00 00    	jbe    801064a8 <allocuvm+0x118>
    mem = kalloc();
8010640d:	e8 22 be ff ff       	call   80102234 <kalloc>
80106412:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106414:	85 c0                	test   %eax,%eax
80106416:	75 b8                	jne    801063d0 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
80106418:	83 ec 0c             	sub    $0xc,%esp
8010641b:	68 e9 70 10 80       	push   $0x801070e9
80106420:	e8 fb a1 ff ff       	call   80100620 <cprintf>
  if(newsz >= oldsz)
80106425:	83 c4 10             	add    $0x10,%esp
80106428:	8b 45 0c             	mov    0xc(%ebp),%eax
8010642b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010642e:	74 2c                	je     8010645c <allocuvm+0xcc>
80106430:	89 c1                	mov    %eax,%ecx
80106432:	8b 55 10             	mov    0x10(%ebp),%edx
80106435:	8b 45 08             	mov    0x8(%ebp),%eax
80106438:	e8 f3 fb ff ff       	call   80106030 <deallocuvm.part.0>
      return 0;
8010643d:	31 ff                	xor    %edi,%edi
}
8010643f:	89 f8                	mov    %edi,%eax
80106441:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106444:	5b                   	pop    %ebx
80106445:	5e                   	pop    %esi
80106446:	5f                   	pop    %edi
80106447:	5d                   	pop    %ebp
80106448:	c3                   	ret    
80106449:	8d 76 00             	lea    0x0(%esi),%esi
    return oldsz;
8010644c:	8b 7d 0c             	mov    0xc(%ebp),%edi
}
8010644f:	89 f8                	mov    %edi,%eax
80106451:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106454:	5b                   	pop    %ebx
80106455:	5e                   	pop    %esi
80106456:	5f                   	pop    %edi
80106457:	5d                   	pop    %ebp
80106458:	c3                   	ret    
80106459:	8d 76 00             	lea    0x0(%esi),%esi
    return 0;
8010645c:	31 ff                	xor    %edi,%edi
}
8010645e:	89 f8                	mov    %edi,%eax
80106460:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106463:	5b                   	pop    %ebx
80106464:	5e                   	pop    %esi
80106465:	5f                   	pop    %edi
80106466:	5d                   	pop    %ebp
80106467:	c3                   	ret    
      cprintf("allocuvm out of memory (2)\n");
80106468:	83 ec 0c             	sub    $0xc,%esp
8010646b:	68 01 71 10 80       	push   $0x80107101
80106470:	e8 ab a1 ff ff       	call   80100620 <cprintf>
  if(newsz >= oldsz)
80106475:	83 c4 10             	add    $0x10,%esp
80106478:	8b 45 0c             	mov    0xc(%ebp),%eax
8010647b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010647e:	74 0d                	je     8010648d <allocuvm+0xfd>
80106480:	89 c1                	mov    %eax,%ecx
80106482:	8b 55 10             	mov    0x10(%ebp),%edx
80106485:	8b 45 08             	mov    0x8(%ebp),%eax
80106488:	e8 a3 fb ff ff       	call   80106030 <deallocuvm.part.0>
      kfree(mem);
8010648d:	83 ec 0c             	sub    $0xc,%esp
80106490:	53                   	push   %ebx
80106491:	e8 0e bc ff ff       	call   801020a4 <kfree>
      return 0;
80106496:	83 c4 10             	add    $0x10,%esp
80106499:	31 ff                	xor    %edi,%edi
}
8010649b:	89 f8                	mov    %edi,%eax
8010649d:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064a0:	5b                   	pop    %ebx
801064a1:	5e                   	pop    %esi
801064a2:	5f                   	pop    %edi
801064a3:	5d                   	pop    %ebp
801064a4:	c3                   	ret    
801064a5:	8d 76 00             	lea    0x0(%esi),%esi
801064a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801064ab:	89 f8                	mov    %edi,%eax
801064ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064b0:	5b                   	pop    %ebx
801064b1:	5e                   	pop    %esi
801064b2:	5f                   	pop    %edi
801064b3:	5d                   	pop    %ebp
801064b4:	c3                   	ret    
801064b5:	8d 76 00             	lea    0x0(%esi),%esi

801064b8 <deallocuvm>:
{
801064b8:	55                   	push   %ebp
801064b9:	89 e5                	mov    %esp,%ebp
801064bb:	8b 45 08             	mov    0x8(%ebp),%eax
801064be:	8b 55 0c             	mov    0xc(%ebp),%edx
801064c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if(newsz >= oldsz)
801064c4:	39 d1                	cmp    %edx,%ecx
801064c6:	73 08                	jae    801064d0 <deallocuvm+0x18>
}
801064c8:	5d                   	pop    %ebp
801064c9:	e9 62 fb ff ff       	jmp    80106030 <deallocuvm.part.0>
801064ce:	66 90                	xchg   %ax,%ax
801064d0:	89 d0                	mov    %edx,%eax
801064d2:	5d                   	pop    %ebp
801064d3:	c3                   	ret    

801064d4 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801064d4:	55                   	push   %ebp
801064d5:	89 e5                	mov    %esp,%ebp
801064d7:	57                   	push   %edi
801064d8:	56                   	push   %esi
801064d9:	53                   	push   %ebx
801064da:	83 ec 0c             	sub    $0xc,%esp
801064dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint i;

  if(pgdir == 0)
801064e0:	85 ff                	test   %edi,%edi
801064e2:	74 51                	je     80106535 <freevm+0x61>
  if(newsz >= oldsz)
801064e4:	31 c9                	xor    %ecx,%ecx
801064e6:	ba 00 00 00 80       	mov    $0x80000000,%edx
801064eb:	89 f8                	mov    %edi,%eax
801064ed:	e8 3e fb ff ff       	call   80106030 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801064f2:	89 fb                	mov    %edi,%ebx
801064f4:	8d b7 00 10 00 00    	lea    0x1000(%edi),%esi
801064fa:	eb 07                	jmp    80106503 <freevm+0x2f>
801064fc:	83 c3 04             	add    $0x4,%ebx
801064ff:	39 de                	cmp    %ebx,%esi
80106501:	74 23                	je     80106526 <freevm+0x52>
    if(pgdir[i] & PTE_P){
80106503:	8b 03                	mov    (%ebx),%eax
80106505:	a8 01                	test   $0x1,%al
80106507:	74 f3                	je     801064fc <freevm+0x28>
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
80106509:	83 ec 0c             	sub    $0xc,%esp
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010650c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106511:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106516:	50                   	push   %eax
80106517:	e8 88 bb ff ff       	call   801020a4 <kfree>
8010651c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010651f:	83 c3 04             	add    $0x4,%ebx
80106522:	39 de                	cmp    %ebx,%esi
80106524:	75 dd                	jne    80106503 <freevm+0x2f>
    }
  }
  kfree((char*)pgdir);
80106526:	89 7d 08             	mov    %edi,0x8(%ebp)
}
80106529:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010652c:	5b                   	pop    %ebx
8010652d:	5e                   	pop    %esi
8010652e:	5f                   	pop    %edi
8010652f:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80106530:	e9 6f bb ff ff       	jmp    801020a4 <kfree>
    panic("freevm: no pgdir");
80106535:	83 ec 0c             	sub    $0xc,%esp
80106538:	68 1d 71 10 80       	push   $0x8010711d
8010653d:	e8 fe 9d ff ff       	call   80100340 <panic>
80106542:	66 90                	xchg   %ax,%ax

80106544 <setupkvm>:
{
80106544:	55                   	push   %ebp
80106545:	89 e5                	mov    %esp,%ebp
80106547:	56                   	push   %esi
80106548:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106549:	e8 e6 bc ff ff       	call   80102234 <kalloc>
8010654e:	89 c6                	mov    %eax,%esi
80106550:	85 c0                	test   %eax,%eax
80106552:	74 40                	je     80106594 <setupkvm+0x50>
  memset(pgdir, 0, PGSIZE);
80106554:	50                   	push   %eax
80106555:	68 00 10 00 00       	push   $0x1000
8010655a:	6a 00                	push   $0x0
8010655c:	56                   	push   %esi
8010655d:	e8 ca db ff ff       	call   8010412c <memset>
80106562:	83 c4 10             	add    $0x10,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106565:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
                (uint)k->phys_start, k->perm) < 0) {
8010656a:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010656d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106570:	29 c1                	sub    %eax,%ecx
80106572:	83 ec 08             	sub    $0x8,%esp
80106575:	ff 73 0c             	pushl  0xc(%ebx)
80106578:	50                   	push   %eax
80106579:	8b 13                	mov    (%ebx),%edx
8010657b:	89 f0                	mov    %esi,%eax
8010657d:	e8 2a fa ff ff       	call   80105fac <mappages>
80106582:	83 c4 10             	add    $0x10,%esp
80106585:	85 c0                	test   %eax,%eax
80106587:	78 17                	js     801065a0 <setupkvm+0x5c>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106589:	83 c3 10             	add    $0x10,%ebx
8010658c:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106592:	75 d6                	jne    8010656a <setupkvm+0x26>
}
80106594:	89 f0                	mov    %esi,%eax
80106596:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106599:	5b                   	pop    %ebx
8010659a:	5e                   	pop    %esi
8010659b:	5d                   	pop    %ebp
8010659c:	c3                   	ret    
8010659d:	8d 76 00             	lea    0x0(%esi),%esi
      freevm(pgdir);
801065a0:	83 ec 0c             	sub    $0xc,%esp
801065a3:	56                   	push   %esi
801065a4:	e8 2b ff ff ff       	call   801064d4 <freevm>
      return 0;
801065a9:	83 c4 10             	add    $0x10,%esp
801065ac:	31 f6                	xor    %esi,%esi
}
801065ae:	89 f0                	mov    %esi,%eax
801065b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801065b3:	5b                   	pop    %ebx
801065b4:	5e                   	pop    %esi
801065b5:	5d                   	pop    %ebp
801065b6:	c3                   	ret    
801065b7:	90                   	nop

801065b8 <kvmalloc>:
{
801065b8:	55                   	push   %ebp
801065b9:	89 e5                	mov    %esp,%ebp
801065bb:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801065be:	e8 81 ff ff ff       	call   80106544 <setupkvm>
801065c3:	a3 84 5f 11 80       	mov    %eax,0x80115f84
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801065c8:	05 00 00 00 80       	add    $0x80000000,%eax
801065cd:	0f 22 d8             	mov    %eax,%cr3
}
801065d0:	c9                   	leave  
801065d1:	c3                   	ret    
801065d2:	66 90                	xchg   %ax,%ax

801065d4 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801065d4:	55                   	push   %ebp
801065d5:	89 e5                	mov    %esp,%ebp
801065d7:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801065da:	31 c9                	xor    %ecx,%ecx
801065dc:	8b 55 0c             	mov    0xc(%ebp),%edx
801065df:	8b 45 08             	mov    0x8(%ebp),%eax
801065e2:	e8 51 f9 ff ff       	call   80105f38 <walkpgdir>
  if(pte == 0)
801065e7:	85 c0                	test   %eax,%eax
801065e9:	74 05                	je     801065f0 <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
801065eb:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801065ee:	c9                   	leave  
801065ef:	c3                   	ret    
    panic("clearpteu");
801065f0:	83 ec 0c             	sub    $0xc,%esp
801065f3:	68 2e 71 10 80       	push   $0x8010712e
801065f8:	e8 43 9d ff ff       	call   80100340 <panic>
801065fd:	8d 76 00             	lea    0x0(%esi),%esi

80106600 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106600:	55                   	push   %ebp
80106601:	89 e5                	mov    %esp,%ebp
80106603:	57                   	push   %edi
80106604:	56                   	push   %esi
80106605:	53                   	push   %ebx
80106606:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106609:	e8 36 ff ff ff       	call   80106544 <setupkvm>
8010660e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106611:	85 c0                	test   %eax,%eax
80106613:	0f 84 96 00 00 00    	je     801066af <copyuvm+0xaf>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106619:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010661c:	85 db                	test   %ebx,%ebx
8010661e:	0f 84 8b 00 00 00    	je     801066af <copyuvm+0xaf>
80106624:	31 ff                	xor    %edi,%edi
80106626:	eb 40                	jmp    80106668 <copyuvm+0x68>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106628:	50                   	push   %eax
80106629:	68 00 10 00 00       	push   $0x1000
8010662e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106631:	05 00 00 00 80       	add    $0x80000000,%eax
80106636:	50                   	push   %eax
80106637:	56                   	push   %esi
80106638:	e8 73 db ff ff       	call   801041b0 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010663d:	5a                   	pop    %edx
8010663e:	59                   	pop    %ecx
8010663f:	53                   	push   %ebx
80106640:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106646:	50                   	push   %eax
80106647:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010664c:	89 fa                	mov    %edi,%edx
8010664e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106651:	e8 56 f9 ff ff       	call   80105fac <mappages>
80106656:	83 c4 10             	add    $0x10,%esp
80106659:	85 c0                	test   %eax,%eax
8010665b:	78 5f                	js     801066bc <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
8010665d:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106663:	39 7d 0c             	cmp    %edi,0xc(%ebp)
80106666:	76 47                	jbe    801066af <copyuvm+0xaf>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106668:	31 c9                	xor    %ecx,%ecx
8010666a:	89 fa                	mov    %edi,%edx
8010666c:	8b 45 08             	mov    0x8(%ebp),%eax
8010666f:	e8 c4 f8 ff ff       	call   80105f38 <walkpgdir>
80106674:	85 c0                	test   %eax,%eax
80106676:	74 5f                	je     801066d7 <copyuvm+0xd7>
    if(!(*pte & PTE_P))
80106678:	8b 18                	mov    (%eax),%ebx
8010667a:	f6 c3 01             	test   $0x1,%bl
8010667d:	74 4b                	je     801066ca <copyuvm+0xca>
    pa = PTE_ADDR(*pte);
8010667f:	89 d8                	mov    %ebx,%eax
80106681:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106686:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    flags = PTE_FLAGS(*pte);
80106689:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
    if((mem = kalloc()) == 0)
8010668f:	e8 a0 bb ff ff       	call   80102234 <kalloc>
80106694:	89 c6                	mov    %eax,%esi
80106696:	85 c0                	test   %eax,%eax
80106698:	75 8e                	jne    80106628 <copyuvm+0x28>
    }
  }
  return d;

bad:
  freevm(d);
8010669a:	83 ec 0c             	sub    $0xc,%esp
8010669d:	ff 75 e0             	pushl  -0x20(%ebp)
801066a0:	e8 2f fe ff ff       	call   801064d4 <freevm>
  return 0;
801066a5:	83 c4 10             	add    $0x10,%esp
801066a8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
}
801066af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801066b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066b5:	5b                   	pop    %ebx
801066b6:	5e                   	pop    %esi
801066b7:	5f                   	pop    %edi
801066b8:	5d                   	pop    %ebp
801066b9:	c3                   	ret    
801066ba:	66 90                	xchg   %ax,%ax
      kfree(mem);
801066bc:	83 ec 0c             	sub    $0xc,%esp
801066bf:	56                   	push   %esi
801066c0:	e8 df b9 ff ff       	call   801020a4 <kfree>
      goto bad;
801066c5:	83 c4 10             	add    $0x10,%esp
801066c8:	eb d0                	jmp    8010669a <copyuvm+0x9a>
      panic("copyuvm: page not present");
801066ca:	83 ec 0c             	sub    $0xc,%esp
801066cd:	68 52 71 10 80       	push   $0x80107152
801066d2:	e8 69 9c ff ff       	call   80100340 <panic>
      panic("copyuvm: pte should exist");
801066d7:	83 ec 0c             	sub    $0xc,%esp
801066da:	68 38 71 10 80       	push   $0x80107138
801066df:	e8 5c 9c ff ff       	call   80100340 <panic>

801066e4 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801066e4:	55                   	push   %ebp
801066e5:	89 e5                	mov    %esp,%ebp
801066e7:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801066ea:	31 c9                	xor    %ecx,%ecx
801066ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801066ef:	8b 45 08             	mov    0x8(%ebp),%eax
801066f2:	e8 41 f8 ff ff       	call   80105f38 <walkpgdir>
  if((*pte & PTE_P) == 0)
801066f7:	8b 00                	mov    (%eax),%eax
    return 0;
  if((*pte & PTE_U) == 0)
801066f9:	89 c2                	mov    %eax,%edx
801066fb:	83 e2 05             	and    $0x5,%edx
801066fe:	83 fa 05             	cmp    $0x5,%edx
80106701:	75 0d                	jne    80106710 <uva2ka+0x2c>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106703:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106708:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010670d:	c9                   	leave  
8010670e:	c3                   	ret    
8010670f:	90                   	nop
    return 0;
80106710:	31 c0                	xor    %eax,%eax
}
80106712:	c9                   	leave  
80106713:	c3                   	ret    

80106714 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106714:	55                   	push   %ebp
80106715:	89 e5                	mov    %esp,%ebp
80106717:	57                   	push   %edi
80106718:	56                   	push   %esi
80106719:	53                   	push   %ebx
8010671a:	83 ec 0c             	sub    $0xc,%esp
8010671d:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106720:	8b 4d 14             	mov    0x14(%ebp),%ecx
80106723:	85 c9                	test   %ecx,%ecx
80106725:	74 65                	je     8010678c <copyout+0x78>
80106727:	89 fb                	mov    %edi,%ebx
80106729:	eb 37                	jmp    80106762 <copyout+0x4e>
8010672b:	90                   	nop
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
8010672c:	89 f2                	mov    %esi,%edx
8010672e:	2b 55 0c             	sub    0xc(%ebp),%edx
    if(n > len)
80106731:	8d ba 00 10 00 00    	lea    0x1000(%edx),%edi
80106737:	3b 7d 14             	cmp    0x14(%ebp),%edi
8010673a:	76 03                	jbe    8010673f <copyout+0x2b>
8010673c:	8b 7d 14             	mov    0x14(%ebp),%edi
      n = len;
    memmove(pa0 + (va - va0), buf, n);
8010673f:	52                   	push   %edx
80106740:	57                   	push   %edi
80106741:	53                   	push   %ebx
80106742:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106745:	29 f1                	sub    %esi,%ecx
80106747:	01 c8                	add    %ecx,%eax
80106749:	50                   	push   %eax
8010674a:	e8 61 da ff ff       	call   801041b0 <memmove>
    len -= n;
    buf += n;
8010674f:	01 fb                	add    %edi,%ebx
    va = va0 + PGSIZE;
80106751:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106757:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010675a:	83 c4 10             	add    $0x10,%esp
8010675d:	29 7d 14             	sub    %edi,0x14(%ebp)
80106760:	74 2a                	je     8010678c <copyout+0x78>
    va0 = (uint)PGROUNDDOWN(va);
80106762:	8b 75 0c             	mov    0xc(%ebp),%esi
80106765:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
8010676b:	83 ec 08             	sub    $0x8,%esp
8010676e:	56                   	push   %esi
8010676f:	ff 75 08             	pushl  0x8(%ebp)
80106772:	e8 6d ff ff ff       	call   801066e4 <uva2ka>
    if(pa0 == 0)
80106777:	83 c4 10             	add    $0x10,%esp
8010677a:	85 c0                	test   %eax,%eax
8010677c:	75 ae                	jne    8010672c <copyout+0x18>
      return -1;
8010677e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80106783:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106786:	5b                   	pop    %ebx
80106787:	5e                   	pop    %esi
80106788:	5f                   	pop    %edi
80106789:	5d                   	pop    %ebp
8010678a:	c3                   	ret    
8010678b:	90                   	nop
  return 0;
8010678c:	31 c0                	xor    %eax,%eax
}
8010678e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106791:	5b                   	pop    %ebx
80106792:	5e                   	pop    %esi
80106793:	5f                   	pop    %edi
80106794:	5d                   	pop    %ebp
80106795:	c3                   	ret    
