
_hello:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	50                   	push   %eax
  int readcount = getreadcount();
   f:	e8 65 02 00 00       	call   279 <getreadcount>
  printf(1, "hello, read count is '%d'\n", readcount);
  14:	52                   	push   %edx
  15:	50                   	push   %eax
  16:	68 18 06 00 00       	push   $0x618
  1b:	6a 01                	push   $0x1
  1d:	e8 ea 02 00 00       	call   30c <printf>
  exit();
  22:	e8 b2 01 00 00       	call   1d9 <exit>
  27:	90                   	nop

00000028 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  28:	55                   	push   %ebp
  29:	89 e5                	mov    %esp,%ebp
  2b:	53                   	push   %ebx
  2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  32:	31 c0                	xor    %eax,%eax
  34:	8a 14 03             	mov    (%ebx,%eax,1),%dl
  37:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  3a:	40                   	inc    %eax
  3b:	84 d2                	test   %dl,%dl
  3d:	75 f5                	jne    34 <strcpy+0xc>
    ;
  return os;
}
  3f:	89 c8                	mov    %ecx,%eax
  41:	5b                   	pop    %ebx
  42:	5d                   	pop    %ebp
  43:	c3                   	ret    

00000044 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  44:	55                   	push   %ebp
  45:	89 e5                	mov    %esp,%ebp
  47:	53                   	push   %ebx
  48:	8b 5d 08             	mov    0x8(%ebp),%ebx
  4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  4e:	0f b6 03             	movzbl (%ebx),%eax
  51:	0f b6 0a             	movzbl (%edx),%ecx
  54:	84 c0                	test   %al,%al
  56:	75 10                	jne    68 <strcmp+0x24>
  58:	eb 1a                	jmp    74 <strcmp+0x30>
  5a:	66 90                	xchg   %ax,%ax
    p++, q++;
  5c:	43                   	inc    %ebx
  5d:	42                   	inc    %edx
  while(*p && *p == *q)
  5e:	0f b6 03             	movzbl (%ebx),%eax
  61:	0f b6 0a             	movzbl (%edx),%ecx
  64:	84 c0                	test   %al,%al
  66:	74 0c                	je     74 <strcmp+0x30>
  68:	38 c8                	cmp    %cl,%al
  6a:	74 f0                	je     5c <strcmp+0x18>
  return (uchar)*p - (uchar)*q;
  6c:	29 c8                	sub    %ecx,%eax
}
  6e:	5b                   	pop    %ebx
  6f:	5d                   	pop    %ebp
  70:	c3                   	ret    
  71:	8d 76 00             	lea    0x0(%esi),%esi
  74:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
  76:	29 c8                	sub    %ecx,%eax
}
  78:	5b                   	pop    %ebx
  79:	5d                   	pop    %ebp
  7a:	c3                   	ret    
  7b:	90                   	nop

0000007c <strlen>:

uint
strlen(const char *s)
{
  7c:	55                   	push   %ebp
  7d:	89 e5                	mov    %esp,%ebp
  7f:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
  82:	80 3a 00             	cmpb   $0x0,(%edx)
  85:	74 15                	je     9c <strlen+0x20>
  87:	31 c0                	xor    %eax,%eax
  89:	8d 76 00             	lea    0x0(%esi),%esi
  8c:	40                   	inc    %eax
  8d:	89 c1                	mov    %eax,%ecx
  8f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  93:	75 f7                	jne    8c <strlen+0x10>
    ;
  return n;
}
  95:	89 c8                	mov    %ecx,%eax
  97:	5d                   	pop    %ebp
  98:	c3                   	ret    
  99:	8d 76 00             	lea    0x0(%esi),%esi
  for(n = 0; s[n]; n++)
  9c:	31 c9                	xor    %ecx,%ecx
}
  9e:	89 c8                	mov    %ecx,%eax
  a0:	5d                   	pop    %ebp
  a1:	c3                   	ret    
  a2:	66 90                	xchg   %ax,%ax

000000a4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a4:	55                   	push   %ebp
  a5:	89 e5                	mov    %esp,%ebp
  a7:	57                   	push   %edi
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
  ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  b1:	fc                   	cld    
  b2:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  b4:	8b 45 08             	mov    0x8(%ebp),%eax
  b7:	5f                   	pop    %edi
  b8:	5d                   	pop    %ebp
  b9:	c3                   	ret    
  ba:	66 90                	xchg   %ax,%ax

000000bc <strchr>:

char*
strchr(const char *s, char c)
{
  bc:	55                   	push   %ebp
  bd:	89 e5                	mov    %esp,%ebp
  bf:	8b 45 08             	mov    0x8(%ebp),%eax
  c2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
  c5:	8a 10                	mov    (%eax),%dl
  c7:	84 d2                	test   %dl,%dl
  c9:	75 0c                	jne    d7 <strchr+0x1b>
  cb:	eb 13                	jmp    e0 <strchr+0x24>
  cd:	8d 76 00             	lea    0x0(%esi),%esi
  d0:	40                   	inc    %eax
  d1:	8a 10                	mov    (%eax),%dl
  d3:	84 d2                	test   %dl,%dl
  d5:	74 09                	je     e0 <strchr+0x24>
    if(*s == c)
  d7:	38 d1                	cmp    %dl,%cl
  d9:	75 f5                	jne    d0 <strchr+0x14>
      return (char*)s;
  return 0;
}
  db:	5d                   	pop    %ebp
  dc:	c3                   	ret    
  dd:	8d 76 00             	lea    0x0(%esi),%esi
  return 0;
  e0:	31 c0                	xor    %eax,%eax
}
  e2:	5d                   	pop    %ebp
  e3:	c3                   	ret    

000000e4 <gets>:

char*
gets(char *buf, int max)
{
  e4:	55                   	push   %ebp
  e5:	89 e5                	mov    %esp,%ebp
  e7:	57                   	push   %edi
  e8:	56                   	push   %esi
  e9:	53                   	push   %ebx
  ea:	83 ec 1c             	sub    $0x1c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  ed:	8b 75 08             	mov    0x8(%ebp),%esi
  f0:	bb 01 00 00 00       	mov    $0x1,%ebx
  f5:	29 f3                	sub    %esi,%ebx
    cc = read(0, &c, 1);
  f7:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
  fa:	eb 20                	jmp    11c <gets+0x38>
    cc = read(0, &c, 1);
  fc:	50                   	push   %eax
  fd:	6a 01                	push   $0x1
  ff:	57                   	push   %edi
 100:	6a 00                	push   $0x0
 102:	e8 ea 00 00 00       	call   1f1 <read>
    if(cc < 1)
 107:	83 c4 10             	add    $0x10,%esp
 10a:	85 c0                	test   %eax,%eax
 10c:	7e 16                	jle    124 <gets+0x40>
      break;
    buf[i++] = c;
 10e:	8a 45 e7             	mov    -0x19(%ebp),%al
 111:	88 06                	mov    %al,(%esi)
    if(c == '\n' || c == '\r')
 113:	46                   	inc    %esi
 114:	3c 0a                	cmp    $0xa,%al
 116:	74 0c                	je     124 <gets+0x40>
 118:	3c 0d                	cmp    $0xd,%al
 11a:	74 08                	je     124 <gets+0x40>
  for(i=0; i+1 < max; ){
 11c:	8d 04 33             	lea    (%ebx,%esi,1),%eax
 11f:	39 45 0c             	cmp    %eax,0xc(%ebp)
 122:	7f d8                	jg     fc <gets+0x18>
      break;
  }
  buf[i] = '\0';
 124:	c6 06 00             	movb   $0x0,(%esi)
  return buf;
}
 127:	8b 45 08             	mov    0x8(%ebp),%eax
 12a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 12d:	5b                   	pop    %ebx
 12e:	5e                   	pop    %esi
 12f:	5f                   	pop    %edi
 130:	5d                   	pop    %ebp
 131:	c3                   	ret    
 132:	66 90                	xchg   %ax,%ax

00000134 <stat>:

int
stat(const char *n, struct stat *st)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	56                   	push   %esi
 138:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 139:	83 ec 08             	sub    $0x8,%esp
 13c:	6a 00                	push   $0x0
 13e:	ff 75 08             	pushl  0x8(%ebp)
 141:	e8 d3 00 00 00       	call   219 <open>
  if(fd < 0)
 146:	83 c4 10             	add    $0x10,%esp
 149:	85 c0                	test   %eax,%eax
 14b:	78 27                	js     174 <stat+0x40>
 14d:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 14f:	83 ec 08             	sub    $0x8,%esp
 152:	ff 75 0c             	pushl  0xc(%ebp)
 155:	50                   	push   %eax
 156:	e8 d6 00 00 00       	call   231 <fstat>
 15b:	89 c6                	mov    %eax,%esi
  close(fd);
 15d:	89 1c 24             	mov    %ebx,(%esp)
 160:	e8 9c 00 00 00       	call   201 <close>
  return r;
 165:	83 c4 10             	add    $0x10,%esp
}
 168:	89 f0                	mov    %esi,%eax
 16a:	8d 65 f8             	lea    -0x8(%ebp),%esp
 16d:	5b                   	pop    %ebx
 16e:	5e                   	pop    %esi
 16f:	5d                   	pop    %ebp
 170:	c3                   	ret    
 171:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
 174:	be ff ff ff ff       	mov    $0xffffffff,%esi
 179:	eb ed                	jmp    168 <stat+0x34>
 17b:	90                   	nop

0000017c <atoi>:

int
atoi(const char *s)
{
 17c:	55                   	push   %ebp
 17d:	89 e5                	mov    %esp,%ebp
 17f:	53                   	push   %ebx
 180:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 183:	0f be 01             	movsbl (%ecx),%eax
 186:	8d 50 d0             	lea    -0x30(%eax),%edx
 189:	80 fa 09             	cmp    $0x9,%dl
  n = 0;
 18c:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
 191:	77 16                	ja     1a9 <atoi+0x2d>
 193:	90                   	nop
    n = n*10 + *s++ - '0';
 194:	41                   	inc    %ecx
 195:	8d 14 92             	lea    (%edx,%edx,4),%edx
 198:	01 d2                	add    %edx,%edx
 19a:	8d 54 02 d0          	lea    -0x30(%edx,%eax,1),%edx
  while('0' <= *s && *s <= '9')
 19e:	0f be 01             	movsbl (%ecx),%eax
 1a1:	8d 58 d0             	lea    -0x30(%eax),%ebx
 1a4:	80 fb 09             	cmp    $0x9,%bl
 1a7:	76 eb                	jbe    194 <atoi+0x18>
  return n;
}
 1a9:	89 d0                	mov    %edx,%eax
 1ab:	5b                   	pop    %ebx
 1ac:	5d                   	pop    %ebp
 1ad:	c3                   	ret    
 1ae:	66 90                	xchg   %ax,%ax

000001b0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
 1b3:	57                   	push   %edi
 1b4:	56                   	push   %esi
 1b5:	8b 45 08             	mov    0x8(%ebp),%eax
 1b8:	8b 75 0c             	mov    0xc(%ebp),%esi
 1bb:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 1be:	85 d2                	test   %edx,%edx
 1c0:	7e 0b                	jle    1cd <memmove+0x1d>
 1c2:	01 c2                	add    %eax,%edx
  dst = vdst;
 1c4:	89 c7                	mov    %eax,%edi
 1c6:	66 90                	xchg   %ax,%ax
    *dst++ = *src++;
 1c8:	a4                   	movsb  %ds:(%esi),%es:(%edi)
  while(n-- > 0)
 1c9:	39 fa                	cmp    %edi,%edx
 1cb:	75 fb                	jne    1c8 <memmove+0x18>
  return vdst;
}
 1cd:	5e                   	pop    %esi
 1ce:	5f                   	pop    %edi
 1cf:	5d                   	pop    %ebp
 1d0:	c3                   	ret    

000001d1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1d1:	b8 01 00 00 00       	mov    $0x1,%eax
 1d6:	cd 40                	int    $0x40
 1d8:	c3                   	ret    

000001d9 <exit>:
SYSCALL(exit)
 1d9:	b8 02 00 00 00       	mov    $0x2,%eax
 1de:	cd 40                	int    $0x40
 1e0:	c3                   	ret    

000001e1 <wait>:
SYSCALL(wait)
 1e1:	b8 03 00 00 00       	mov    $0x3,%eax
 1e6:	cd 40                	int    $0x40
 1e8:	c3                   	ret    

000001e9 <pipe>:
SYSCALL(pipe)
 1e9:	b8 04 00 00 00       	mov    $0x4,%eax
 1ee:	cd 40                	int    $0x40
 1f0:	c3                   	ret    

000001f1 <read>:
SYSCALL(read)
 1f1:	b8 05 00 00 00       	mov    $0x5,%eax
 1f6:	cd 40                	int    $0x40
 1f8:	c3                   	ret    

000001f9 <write>:
SYSCALL(write)
 1f9:	b8 10 00 00 00       	mov    $0x10,%eax
 1fe:	cd 40                	int    $0x40
 200:	c3                   	ret    

00000201 <close>:
SYSCALL(close)
 201:	b8 15 00 00 00       	mov    $0x15,%eax
 206:	cd 40                	int    $0x40
 208:	c3                   	ret    

00000209 <kill>:
SYSCALL(kill)
 209:	b8 06 00 00 00       	mov    $0x6,%eax
 20e:	cd 40                	int    $0x40
 210:	c3                   	ret    

00000211 <exec>:
SYSCALL(exec)
 211:	b8 07 00 00 00       	mov    $0x7,%eax
 216:	cd 40                	int    $0x40
 218:	c3                   	ret    

00000219 <open>:
SYSCALL(open)
 219:	b8 0f 00 00 00       	mov    $0xf,%eax
 21e:	cd 40                	int    $0x40
 220:	c3                   	ret    

00000221 <mknod>:
SYSCALL(mknod)
 221:	b8 11 00 00 00       	mov    $0x11,%eax
 226:	cd 40                	int    $0x40
 228:	c3                   	ret    

00000229 <unlink>:
SYSCALL(unlink)
 229:	b8 12 00 00 00       	mov    $0x12,%eax
 22e:	cd 40                	int    $0x40
 230:	c3                   	ret    

00000231 <fstat>:
SYSCALL(fstat)
 231:	b8 08 00 00 00       	mov    $0x8,%eax
 236:	cd 40                	int    $0x40
 238:	c3                   	ret    

00000239 <link>:
SYSCALL(link)
 239:	b8 13 00 00 00       	mov    $0x13,%eax
 23e:	cd 40                	int    $0x40
 240:	c3                   	ret    

00000241 <mkdir>:
SYSCALL(mkdir)
 241:	b8 14 00 00 00       	mov    $0x14,%eax
 246:	cd 40                	int    $0x40
 248:	c3                   	ret    

00000249 <chdir>:
SYSCALL(chdir)
 249:	b8 09 00 00 00       	mov    $0x9,%eax
 24e:	cd 40                	int    $0x40
 250:	c3                   	ret    

00000251 <dup>:
SYSCALL(dup)
 251:	b8 0a 00 00 00       	mov    $0xa,%eax
 256:	cd 40                	int    $0x40
 258:	c3                   	ret    

00000259 <getpid>:
SYSCALL(getpid)
 259:	b8 0b 00 00 00       	mov    $0xb,%eax
 25e:	cd 40                	int    $0x40
 260:	c3                   	ret    

00000261 <sbrk>:
SYSCALL(sbrk)
 261:	b8 0c 00 00 00       	mov    $0xc,%eax
 266:	cd 40                	int    $0x40
 268:	c3                   	ret    

00000269 <sleep>:
SYSCALL(sleep)
 269:	b8 0d 00 00 00       	mov    $0xd,%eax
 26e:	cd 40                	int    $0x40
 270:	c3                   	ret    

00000271 <uptime>:
SYSCALL(uptime)
 271:	b8 0e 00 00 00       	mov    $0xe,%eax
 276:	cd 40                	int    $0x40
 278:	c3                   	ret    

00000279 <getreadcount>:
SYSCALL(getreadcount)
 279:	b8 16 00 00 00       	mov    $0x16,%eax
 27e:	cd 40                	int    $0x40
 280:	c3                   	ret    
 281:	66 90                	xchg   %ax,%ax
 283:	90                   	nop

00000284 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 284:	55                   	push   %ebp
 285:	89 e5                	mov    %esp,%ebp
 287:	57                   	push   %edi
 288:	56                   	push   %esi
 289:	53                   	push   %ebx
 28a:	83 ec 3c             	sub    $0x3c,%esp
 28d:	89 45 bc             	mov    %eax,-0x44(%ebp)
 290:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 293:	89 d1                	mov    %edx,%ecx
  if(sgn && xx < 0){
 295:	8b 5d 08             	mov    0x8(%ebp),%ebx
 298:	85 db                	test   %ebx,%ebx
 29a:	74 04                	je     2a0 <printint+0x1c>
 29c:	85 d2                	test   %edx,%edx
 29e:	78 68                	js     308 <printint+0x84>
  neg = 0;
 2a0:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2a7:	31 ff                	xor    %edi,%edi
 2a9:	8d 75 d7             	lea    -0x29(%ebp),%esi
  do{
    buf[i++] = digits[x % base];
 2ac:	89 c8                	mov    %ecx,%eax
 2ae:	31 d2                	xor    %edx,%edx
 2b0:	f7 75 c4             	divl   -0x3c(%ebp)
 2b3:	89 fb                	mov    %edi,%ebx
 2b5:	8d 7f 01             	lea    0x1(%edi),%edi
 2b8:	8a 92 3c 06 00 00    	mov    0x63c(%edx),%dl
 2be:	88 54 1e 01          	mov    %dl,0x1(%esi,%ebx,1)
  }while((x /= base) != 0);
 2c2:	89 4d c0             	mov    %ecx,-0x40(%ebp)
 2c5:	89 c1                	mov    %eax,%ecx
 2c7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 2ca:	3b 45 c0             	cmp    -0x40(%ebp),%eax
 2cd:	76 dd                	jbe    2ac <printint+0x28>
  if(neg)
 2cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2d2:	85 c9                	test   %ecx,%ecx
 2d4:	74 09                	je     2df <printint+0x5b>
    buf[i++] = '-';
 2d6:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
    buf[i++] = digits[x % base];
 2db:	89 fb                	mov    %edi,%ebx
    buf[i++] = '-';
 2dd:	b2 2d                	mov    $0x2d,%dl

  while(--i >= 0)
 2df:	8d 5c 1d d7          	lea    -0x29(%ebp,%ebx,1),%ebx
 2e3:	8b 7d bc             	mov    -0x44(%ebp),%edi
 2e6:	eb 03                	jmp    2eb <printint+0x67>
 2e8:	8a 13                	mov    (%ebx),%dl
 2ea:	4b                   	dec    %ebx
    putc(fd, buf[i]);
 2eb:	88 55 d7             	mov    %dl,-0x29(%ebp)
  write(fd, &c, 1);
 2ee:	50                   	push   %eax
 2ef:	6a 01                	push   $0x1
 2f1:	56                   	push   %esi
 2f2:	57                   	push   %edi
 2f3:	e8 01 ff ff ff       	call   1f9 <write>
  while(--i >= 0)
 2f8:	83 c4 10             	add    $0x10,%esp
 2fb:	39 de                	cmp    %ebx,%esi
 2fd:	75 e9                	jne    2e8 <printint+0x64>
}
 2ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
 302:	5b                   	pop    %ebx
 303:	5e                   	pop    %esi
 304:	5f                   	pop    %edi
 305:	5d                   	pop    %ebp
 306:	c3                   	ret    
 307:	90                   	nop
    x = -xx;
 308:	f7 d9                	neg    %ecx
 30a:	eb 9b                	jmp    2a7 <printint+0x23>

0000030c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 30c:	55                   	push   %ebp
 30d:	89 e5                	mov    %esp,%ebp
 30f:	57                   	push   %edi
 310:	56                   	push   %esi
 311:	53                   	push   %ebx
 312:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 315:	8b 75 0c             	mov    0xc(%ebp),%esi
 318:	8a 1e                	mov    (%esi),%bl
 31a:	84 db                	test   %bl,%bl
 31c:	0f 84 a3 00 00 00    	je     3c5 <printf+0xb9>
 322:	46                   	inc    %esi
  ap = (uint*)(void*)&fmt + 1;
 323:	8d 45 10             	lea    0x10(%ebp),%eax
 326:	89 45 d0             	mov    %eax,-0x30(%ebp)
  state = 0;
 329:	31 d2                	xor    %edx,%edx
  write(fd, &c, 1);
 32b:	8d 7d e7             	lea    -0x19(%ebp),%edi
 32e:	eb 29                	jmp    359 <printf+0x4d>
 330:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 333:	83 f8 25             	cmp    $0x25,%eax
 336:	0f 84 94 00 00 00    	je     3d0 <printf+0xc4>
        state = '%';
      } else {
        putc(fd, c);
 33c:	88 5d e7             	mov    %bl,-0x19(%ebp)
  write(fd, &c, 1);
 33f:	50                   	push   %eax
 340:	6a 01                	push   $0x1
 342:	57                   	push   %edi
 343:	ff 75 08             	pushl  0x8(%ebp)
 346:	e8 ae fe ff ff       	call   1f9 <write>
        putc(fd, c);
 34b:	83 c4 10             	add    $0x10,%esp
 34e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  for(i = 0; fmt[i]; i++){
 351:	46                   	inc    %esi
 352:	8a 5e ff             	mov    -0x1(%esi),%bl
 355:	84 db                	test   %bl,%bl
 357:	74 6c                	je     3c5 <printf+0xb9>
    c = fmt[i] & 0xff;
 359:	0f be cb             	movsbl %bl,%ecx
 35c:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 35f:	85 d2                	test   %edx,%edx
 361:	74 cd                	je     330 <printf+0x24>
      }
    } else if(state == '%'){
 363:	83 fa 25             	cmp    $0x25,%edx
 366:	75 e9                	jne    351 <printf+0x45>
      if(c == 'd'){
 368:	83 f8 64             	cmp    $0x64,%eax
 36b:	0f 84 97 00 00 00    	je     408 <printf+0xfc>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 371:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 377:	83 f9 70             	cmp    $0x70,%ecx
 37a:	74 60                	je     3dc <printf+0xd0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 37c:	83 f8 73             	cmp    $0x73,%eax
 37f:	0f 84 8f 00 00 00    	je     414 <printf+0x108>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 385:	83 f8 63             	cmp    $0x63,%eax
 388:	0f 84 d6 00 00 00    	je     464 <printf+0x158>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 38e:	83 f8 25             	cmp    $0x25,%eax
 391:	0f 84 c1 00 00 00    	je     458 <printf+0x14c>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 397:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
  write(fd, &c, 1);
 39b:	50                   	push   %eax
 39c:	6a 01                	push   $0x1
 39e:	57                   	push   %edi
 39f:	ff 75 08             	pushl  0x8(%ebp)
 3a2:	e8 52 fe ff ff       	call   1f9 <write>
        putc(fd, c);
 3a7:	88 5d e7             	mov    %bl,-0x19(%ebp)
  write(fd, &c, 1);
 3aa:	83 c4 0c             	add    $0xc,%esp
 3ad:	6a 01                	push   $0x1
 3af:	57                   	push   %edi
 3b0:	ff 75 08             	pushl  0x8(%ebp)
 3b3:	e8 41 fe ff ff       	call   1f9 <write>
        putc(fd, c);
 3b8:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 3bb:	31 d2                	xor    %edx,%edx
  for(i = 0; fmt[i]; i++){
 3bd:	46                   	inc    %esi
 3be:	8a 5e ff             	mov    -0x1(%esi),%bl
 3c1:	84 db                	test   %bl,%bl
 3c3:	75 94                	jne    359 <printf+0x4d>
    }
  }
}
 3c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3c8:	5b                   	pop    %ebx
 3c9:	5e                   	pop    %esi
 3ca:	5f                   	pop    %edi
 3cb:	5d                   	pop    %ebp
 3cc:	c3                   	ret    
 3cd:	8d 76 00             	lea    0x0(%esi),%esi
        state = '%';
 3d0:	ba 25 00 00 00       	mov    $0x25,%edx
 3d5:	e9 77 ff ff ff       	jmp    351 <printf+0x45>
 3da:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 16, 0);
 3dc:	83 ec 0c             	sub    $0xc,%esp
 3df:	6a 00                	push   $0x0
 3e1:	b9 10 00 00 00       	mov    $0x10,%ecx
 3e6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 3e9:	8b 13                	mov    (%ebx),%edx
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	e8 91 fe ff ff       	call   284 <printint>
        ap++;
 3f3:	89 d8                	mov    %ebx,%eax
 3f5:	83 c0 04             	add    $0x4,%eax
 3f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
 3fb:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3fe:	31 d2                	xor    %edx,%edx
        ap++;
 400:	e9 4c ff ff ff       	jmp    351 <printf+0x45>
 405:	8d 76 00             	lea    0x0(%esi),%esi
        printint(fd, *ap, 10, 1);
 408:	83 ec 0c             	sub    $0xc,%esp
 40b:	6a 01                	push   $0x1
 40d:	b9 0a 00 00 00       	mov    $0xa,%ecx
 412:	eb d2                	jmp    3e6 <printf+0xda>
        s = (char*)*ap;
 414:	8b 45 d0             	mov    -0x30(%ebp),%eax
 417:	8b 18                	mov    (%eax),%ebx
        ap++;
 419:	83 c0 04             	add    $0x4,%eax
 41c:	89 45 d0             	mov    %eax,-0x30(%ebp)
        if(s == 0)
 41f:	85 db                	test   %ebx,%ebx
 421:	74 65                	je     488 <printf+0x17c>
        while(*s != 0){
 423:	8a 03                	mov    (%ebx),%al
 425:	84 c0                	test   %al,%al
 427:	74 70                	je     499 <printf+0x18d>
 429:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 42c:	89 de                	mov    %ebx,%esi
 42e:	8b 5d 08             	mov    0x8(%ebp),%ebx
 431:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 434:	88 45 e7             	mov    %al,-0x19(%ebp)
  write(fd, &c, 1);
 437:	50                   	push   %eax
 438:	6a 01                	push   $0x1
 43a:	57                   	push   %edi
 43b:	53                   	push   %ebx
 43c:	e8 b8 fd ff ff       	call   1f9 <write>
          s++;
 441:	46                   	inc    %esi
        while(*s != 0){
 442:	8a 06                	mov    (%esi),%al
 444:	83 c4 10             	add    $0x10,%esp
 447:	84 c0                	test   %al,%al
 449:	75 e9                	jne    434 <printf+0x128>
 44b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
      state = 0;
 44e:	31 d2                	xor    %edx,%edx
 450:	e9 fc fe ff ff       	jmp    351 <printf+0x45>
 455:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
 458:	88 5d e7             	mov    %bl,-0x19(%ebp)
  write(fd, &c, 1);
 45b:	52                   	push   %edx
 45c:	e9 4c ff ff ff       	jmp    3ad <printf+0xa1>
 461:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, *ap);
 464:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 467:	8b 03                	mov    (%ebx),%eax
 469:	88 45 e7             	mov    %al,-0x19(%ebp)
  write(fd, &c, 1);
 46c:	51                   	push   %ecx
 46d:	6a 01                	push   $0x1
 46f:	57                   	push   %edi
 470:	ff 75 08             	pushl  0x8(%ebp)
 473:	e8 81 fd ff ff       	call   1f9 <write>
        ap++;
 478:	83 c3 04             	add    $0x4,%ebx
 47b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 47e:	83 c4 10             	add    $0x10,%esp
      state = 0;
 481:	31 d2                	xor    %edx,%edx
 483:	e9 c9 fe ff ff       	jmp    351 <printf+0x45>
          s = "(null)";
 488:	bb 33 06 00 00       	mov    $0x633,%ebx
        while(*s != 0){
 48d:	b0 28                	mov    $0x28,%al
 48f:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 492:	89 de                	mov    %ebx,%esi
 494:	8b 5d 08             	mov    0x8(%ebp),%ebx
 497:	eb 9b                	jmp    434 <printf+0x128>
      state = 0;
 499:	31 d2                	xor    %edx,%edx
 49b:	e9 b1 fe ff ff       	jmp    351 <printf+0x45>

000004a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4a0:	55                   	push   %ebp
 4a1:	89 e5                	mov    %esp,%ebp
 4a3:	57                   	push   %edi
 4a4:	56                   	push   %esi
 4a5:	53                   	push   %ebx
 4a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4a9:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4ac:	a1 d4 08 00 00       	mov    0x8d4,%eax
 4b1:	8b 10                	mov    (%eax),%edx
 4b3:	39 c8                	cmp    %ecx,%eax
 4b5:	73 11                	jae    4c8 <free+0x28>
 4b7:	90                   	nop
 4b8:	39 d1                	cmp    %edx,%ecx
 4ba:	72 14                	jb     4d0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4bc:	39 d0                	cmp    %edx,%eax
 4be:	73 10                	jae    4d0 <free+0x30>
{
 4c0:	89 d0                	mov    %edx,%eax
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4c2:	8b 10                	mov    (%eax),%edx
 4c4:	39 c8                	cmp    %ecx,%eax
 4c6:	72 f0                	jb     4b8 <free+0x18>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4c8:	39 d0                	cmp    %edx,%eax
 4ca:	72 f4                	jb     4c0 <free+0x20>
 4cc:	39 d1                	cmp    %edx,%ecx
 4ce:	73 f0                	jae    4c0 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4d0:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4d3:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4d6:	39 fa                	cmp    %edi,%edx
 4d8:	74 1a                	je     4f4 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4da:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4dd:	8b 50 04             	mov    0x4(%eax),%edx
 4e0:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4e3:	39 f1                	cmp    %esi,%ecx
 4e5:	74 24                	je     50b <free+0x6b>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4e7:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4e9:	a3 d4 08 00 00       	mov    %eax,0x8d4
}
 4ee:	5b                   	pop    %ebx
 4ef:	5e                   	pop    %esi
 4f0:	5f                   	pop    %edi
 4f1:	5d                   	pop    %ebp
 4f2:	c3                   	ret    
 4f3:	90                   	nop
    bp->s.size += p->s.ptr->s.size;
 4f4:	03 72 04             	add    0x4(%edx),%esi
 4f7:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4fa:	8b 10                	mov    (%eax),%edx
 4fc:	8b 12                	mov    (%edx),%edx
 4fe:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 501:	8b 50 04             	mov    0x4(%eax),%edx
 504:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 507:	39 f1                	cmp    %esi,%ecx
 509:	75 dc                	jne    4e7 <free+0x47>
    p->s.size += bp->s.size;
 50b:	03 53 fc             	add    -0x4(%ebx),%edx
 50e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 511:	8b 53 f8             	mov    -0x8(%ebx),%edx
 514:	89 10                	mov    %edx,(%eax)
  freep = p;
 516:	a3 d4 08 00 00       	mov    %eax,0x8d4
}
 51b:	5b                   	pop    %ebx
 51c:	5e                   	pop    %esi
 51d:	5f                   	pop    %edi
 51e:	5d                   	pop    %ebp
 51f:	c3                   	ret    

00000520 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 520:	55                   	push   %ebp
 521:	89 e5                	mov    %esp,%ebp
 523:	57                   	push   %edi
 524:	56                   	push   %esi
 525:	53                   	push   %ebx
 526:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 529:	8b 45 08             	mov    0x8(%ebp),%eax
 52c:	8d 70 07             	lea    0x7(%eax),%esi
 52f:	c1 ee 03             	shr    $0x3,%esi
 532:	46                   	inc    %esi
  if((prevp = freep) == 0){
 533:	8b 3d d4 08 00 00    	mov    0x8d4,%edi
 539:	85 ff                	test   %edi,%edi
 53b:	0f 84 a3 00 00 00    	je     5e4 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 541:	8b 07                	mov    (%edi),%eax
    if(p->s.size >= nunits){
 543:	8b 48 04             	mov    0x4(%eax),%ecx
 546:	39 f1                	cmp    %esi,%ecx
 548:	73 67                	jae    5b1 <malloc+0x91>
 54a:	89 f3                	mov    %esi,%ebx
 54c:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
 552:	0f 82 80 00 00 00    	jb     5d8 <malloc+0xb8>
  p = sbrk(nu * sizeof(Header));
 558:	8d 0c dd 00 00 00 00 	lea    0x0(,%ebx,8),%ecx
 55f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
 562:	eb 11                	jmp    575 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 564:	8b 10                	mov    (%eax),%edx
    if(p->s.size >= nunits){
 566:	8b 4a 04             	mov    0x4(%edx),%ecx
 569:	39 f1                	cmp    %esi,%ecx
 56b:	73 4b                	jae    5b8 <malloc+0x98>
 56d:	8b 3d d4 08 00 00    	mov    0x8d4,%edi
 573:	89 d0                	mov    %edx,%eax
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 575:	39 c7                	cmp    %eax,%edi
 577:	75 eb                	jne    564 <malloc+0x44>
  p = sbrk(nu * sizeof(Header));
 579:	83 ec 0c             	sub    $0xc,%esp
 57c:	ff 75 e4             	pushl  -0x1c(%ebp)
 57f:	e8 dd fc ff ff       	call   261 <sbrk>
  if(p == (char*)-1)
 584:	83 c4 10             	add    $0x10,%esp
 587:	83 f8 ff             	cmp    $0xffffffff,%eax
 58a:	74 1b                	je     5a7 <malloc+0x87>
  hp->s.size = nu;
 58c:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 58f:	83 ec 0c             	sub    $0xc,%esp
 592:	83 c0 08             	add    $0x8,%eax
 595:	50                   	push   %eax
 596:	e8 05 ff ff ff       	call   4a0 <free>
  return freep;
 59b:	a1 d4 08 00 00       	mov    0x8d4,%eax
      if((p = morecore(nunits)) == 0)
 5a0:	83 c4 10             	add    $0x10,%esp
 5a3:	85 c0                	test   %eax,%eax
 5a5:	75 bd                	jne    564 <malloc+0x44>
        return 0;
 5a7:	31 c0                	xor    %eax,%eax
  }
}
 5a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5ac:	5b                   	pop    %ebx
 5ad:	5e                   	pop    %esi
 5ae:	5f                   	pop    %edi
 5af:	5d                   	pop    %ebp
 5b0:	c3                   	ret    
    if(p->s.size >= nunits){
 5b1:	89 c2                	mov    %eax,%edx
 5b3:	89 f8                	mov    %edi,%eax
 5b5:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->s.size == nunits)
 5b8:	39 ce                	cmp    %ecx,%esi
 5ba:	74 54                	je     610 <malloc+0xf0>
        p->s.size -= nunits;
 5bc:	29 f1                	sub    %esi,%ecx
 5be:	89 4a 04             	mov    %ecx,0x4(%edx)
        p += p->s.size;
 5c1:	8d 14 ca             	lea    (%edx,%ecx,8),%edx
        p->s.size = nunits;
 5c4:	89 72 04             	mov    %esi,0x4(%edx)
      freep = prevp;
 5c7:	a3 d4 08 00 00       	mov    %eax,0x8d4
      return (void*)(p + 1);
 5cc:	8d 42 08             	lea    0x8(%edx),%eax
}
 5cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5d2:	5b                   	pop    %ebx
 5d3:	5e                   	pop    %esi
 5d4:	5f                   	pop    %edi
 5d5:	5d                   	pop    %ebp
 5d6:	c3                   	ret    
 5d7:	90                   	nop
 5d8:	bb 00 10 00 00       	mov    $0x1000,%ebx
 5dd:	e9 76 ff ff ff       	jmp    558 <malloc+0x38>
 5e2:	66 90                	xchg   %ax,%ax
    base.s.ptr = freep = prevp = &base;
 5e4:	c7 05 d4 08 00 00 d8 	movl   $0x8d8,0x8d4
 5eb:	08 00 00 
 5ee:	c7 05 d8 08 00 00 d8 	movl   $0x8d8,0x8d8
 5f5:	08 00 00 
    base.s.size = 0;
 5f8:	c7 05 dc 08 00 00 00 	movl   $0x0,0x8dc
 5ff:	00 00 00 
 602:	bf d8 08 00 00       	mov    $0x8d8,%edi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 607:	89 f8                	mov    %edi,%eax
 609:	e9 3c ff ff ff       	jmp    54a <malloc+0x2a>
 60e:	66 90                	xchg   %ax,%ax
        prevp->s.ptr = p->s.ptr;
 610:	8b 0a                	mov    (%edx),%ecx
 612:	89 08                	mov    %ecx,(%eax)
 614:	eb b1                	jmp    5c7 <malloc+0xa7>
