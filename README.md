# motor-controller

## Development
### Compiler
> [Download MikroC PRO for PIC 7.2.0 CRACK w/o demo limit](https://drive.google.com/file/d/13h_AZg2iz8p9TbDjfSOTVsux-VSJJfBv/view)

### Setup & Compile
1. Find IP address that is not occupied in your local network
2. Set it in `./src/source/pic_source_code.c` to variable `IPAddr`
3. Compile project with downloaded version of MikroC

Connection can be checked via terminal or browser
```console
ping IPAddr
```