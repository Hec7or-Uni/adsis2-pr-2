# ns1

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

### ns1

```
doas vi /var/nsd/etc/nsd.conf
doas nsd-checkconf /var/nsd/etc/nsd.conf
```

```
configuracion...
```

```
cd /var/nsd/zones
doas touch 7.ff.es.eu.org.directo
doas touch 7.ff.es.eu.org.inverso

doas nsd-checkzone ff.es.eu.org.
doas nsd-checkzone 7.0.b.6.3.7.0.7.4.0.1.0.0.2.ip6.arpa.
```

preparar certificados para gestion en primario y copia:
``` 
nsd-control-setup
```

``` 
doas rcctl enable nsd
doas rcctl start nsd
```

```
doas tail -f /var/log/nsd.log
```

```
# en el maestro
doas nsd-control reload 7.ff.es.eu.org
doas nsd-control reload 7.0.b.6.3.7.0.7.4.0.1.0.0.2.ip6.arpa
# en el esclavo
doas nsd-control force_transfer 7.ff.es.eu.org
doas nsd-control force_transfer 7.0.b.6.3.7.0.7.4.0.1.0.0.2.ip6.arpa
# comprobar si se actualiza la version (esclavo??)
doas nsd-control zonestatus
# Volcar la BBDD al fichero de zona en el esclavo (esclavo)
doas nsd-control write 7.ff.es.eu.org
doas nsd-control write 7.0.b.6.3.7.0.7.4.0.1.0.0.2.ip6.arpa
```

## Referencias

- [ref1]()
- [ref2]()
- [ref3]()
- [ref4]()
