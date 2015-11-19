# ping-analyser

Generate stats on your ping output. 

First run you ping and redirect the output into a file (if you want see the ping at the same time, use [tee](https://en.wikipedia.org/wiki/Tee_(command)))

```bash
ping google.fr > ~/ping.log
```

Then run the analyser on that file

```bash
watch -n 1 ruby ping-analyser.rb ~/ping.log
```

