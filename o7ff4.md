# ns2

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


### NTP - cliente

```
doas vi /etc/ntpd.conf
```

```
listen on 2001:470:736b:7ff::2	        # Interfaz de escucha de anuncios de hora
server 2001:470:736b:7ff::2 trusted	    # Servidor de donde escucha ntpd. Trusted -> ajustar hora al inicio
query from 2001:470:736b:7ff::2	        # Si no pones el query from no recibes respuesta
```

```
tail /var/log/daemon | grep ntpd
```

>> **Warning**: Para que el cliente sincronice la hora, nuestro servidor ntp (o7ff2) debe estar sincronizado con una entrada clock `is now synced` si no lo esta, el cliente obtendr;a una entrada de log: `clock is not synced (alarm) next query in 32xxs`

### Paso 2

## Referencias

- [ref1]()
- [ref2]()
- [ref3]()
- [ref4]()
