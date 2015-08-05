#!/bin/bash
## @author iknaxio
## @date 04/08/2015

## dropbox exclude add /home/iknaxio/Dropbox/.encrypt/.encfs6.xml ???

ENC_PRV=/home/iknaxio/Dropbox/.encrypt
ENC_DIR=/home/iknaxio/Priv_Box
TMP_PASS=`mktemp --suffix=ikn_`
LBL_ENC="Mount Encrypt Dir"

MSG01="Se va a proceder a montar $ENC_DIR. Ingrese password:"
MSG02="$ENC_DIR montado exitosamente"
MSG03="Error al montar $ENC_DIR"
MSG04="No se pudo montar $ENC_DIR, desea intentar nuevamente?"
MSG05="Se aborto proceso para montar $ENC_DIR"

function _mount_enc {
  _r=1980
  kdialog --title "$LBL_ENC" --password "$MSG01" > $TMP_PASS
  if [ $? -eq 0 ]
  then
    encfs --extpass="cat $TMP_PASS" $ENC_PRV $ENC_DIR
    _r=$?
    rm -f $TMP_PASS
  fi

  return $_r
}

echo $LBL_ENC $ENC_DIR

while [ 1 -eq 1 ]
do
  _mount_enc
  mnt=$?

  case $mnt in
    0)
      kdialog --title "$LBL_ENC" --passivepopup "$MSG02" 4
      exit 0
      ;;
    1)
      logger -f /var/log/syslog [MOUNT_ENCRYPT_ERROR] $LBL_ENC $ENC_DIR
      kdialog --title "$LBL_ENC" --passivepopup "$MSG03" 4
      kdialog --title "$LBL_ENC" --yesno "$MSG04"

      if [ $? -eq 1 ]
      then
        kdialog --title "$LBL_ENC" --passivepopup "$MSG05" 4
        exit 1
      fi
      ;;
    1980)
      kdialog --title "$LBL_ENC" --passivepopup "$MSG05" 4
      exit 1
      ;;
  esac
done
