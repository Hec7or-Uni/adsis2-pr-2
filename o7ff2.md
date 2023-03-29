# ntp1

## Configuracion

### Maquina

```
doas vi /etc/hosts
```

```
configuracion...
```

```
doas vi /etc/myname
```

```
configuracion...
```

```
doas vi /etc/resolv.conf
```

```
configuracion...
```


### NTP

```bash
doas vi /etc/ntpd.conf
```

```
Aqui va la conf
```


Por ultimo comprobamos que la configuracion es valida con el siguiente comando:
```bash
ntpd -n 
```

```bash
doas rcctl enable ntpd
doas rcctl start ntpd
```

```bash
o7ff2$ doas rcctl stop ntpd
ntpd(ok)

o7ff2$ doas date 202303090011
Fri Mar  9 00:11:00 CET 2023

o7ff2$ doas rcctl start ntpd  
ntpd(ok)
```


```bash
tail /var/log/daemon | grep ntpd
```

### Unbound

```
doas vi /var/unbound/etc/unbound.conf
```

```
doas rcctl enable unbound
doas rcctl start unbound
```

```
doas tail -f /var/log/daemon | grep unbound
```

pruebitas de resolucion
```
host ns1.6.ff.es.eu.org.
host 2001:470:736b:7ff::3
dig @2001:470:736b:7ff::2 ns1.7.ff.es.eu.org
dig @2001:470:736b:7ff::2 -x 2001:470:736b:7ff::2
```

## Referencias

- [ref1]()
- [ref2]()
- [ref3]()
- [ref4]()
