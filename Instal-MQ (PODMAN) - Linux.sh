#!/bin/bash

######################################################################################## 
######################################################################################## 
#### DETALLE: Script de INSTALACIÓN de instancia de IBM MQ contenerizado con PODMAN ####
#### FECHA:   05/02/2025   ############################################################# 
#### OWNER:   Cesar Guerra ############################################################# 
######################################################################################## 
######################################################################################## 
 
#### DECLARACIÓN DE VARIABLES: #### 
vENTITLEMENT_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE3Mzk3NTkxOTcsImp0aSI6IjhlOTUxYjc4ZDhlYzRkZDE5ZmM0ZDY5MmQ5NDJlYTMzIn0.731It6XkJ6XRYDZHiXCPVBZfRJy1YOGctJfk7Pu58qg
vIMAGE_HOST_ENT_KEY=cp.icr.io
vID_IMAGE=$(podman images | grep 'ibm-messaging' | head -n 1 | awk '{print $3}')
vID_CONTAINER=$(podman ps -a | grep 'ibm-messaging' | head -n 1 | awk '{print $1}') 
vIP_FLOTANTE=150.239.171.251 
vNETWORK_NAME=ipv4_network 
vIMAGE_HOST=icr.io
vIMAGE_NAME=icr.io/ibm-messaging/mq
vIMAGE_VERSION=9.4.1.1-r1
vPORT_MQ=1414
vPORT_AMQP=5672
vPORT_HTTPS=9443
vMQ_MQM=MQM01
vMQ_PASSWORD=passw0rd 
vMQ_CUSTOM_NAME=mqm-01
vTIME_SLEEP_01=40
vTIME_SLEEP_02=4
 
echo "*. CONFIGURACIÓN DE PARAMETROS:"
echo "- vENTITLEMENT_KEY: [${vENTITLEMENT_KEY}]"  
echo "- vIMAGE_HOST_ENT_KEY: [${vIMAGE_HOST_ENT_KEY}]" 
echo "- vID_IMAGE: [${vID_IMAGE}]"
echo "- vID_CONTAINER: [${vID_CONTAINER}]"
echo "- vIP_FLOTANTE: [${vIP_FLOTANTE}]"
echo "- vNETWORK_NAME: [${vNETWORK_NAME}]"
echo "- vIMAGE_HOST: [${vIMAGE_HOST}]"
echo "- vIMAGE_NAME: [${vIMAGE_NAME}]"
echo "- vIMAGE_VERSION: [${vIMAGE_VERSION}]"
echo "- vPORT_MQ: [${vPORT_MQ}]"
echo "- vPORT_AMQP: [${vPORT_AMQP}]"
echo "- vPORT_HTTPS: [${vPORT_HTTPS}]"    
echo "- vMQ_MQM: [${vMQ_MQM}]"  
echo "- vMQ_PASSWORD: [${vMQ_PASSWORD}]"  
echo "- vMQ_CUSTOM_NAME: [${vMQ_CUSTOM_NAME}]"  
echo "- vTIME_SLEEP_01: [${vTIME_SLEEP_01}]"  
echo "- vTIME_SLEEP_02: [${vTIME_SLEEP_02}]"    
echo ""
  
#### CONFIGURACIÓN DE MÉTODOS: ####  
probando_dependencias(){
  echo "*. PROBANDO DEPENDENCIAS:"
  echo "cat /etc/os-release"
  cat /etc/os-release
  echo "java -version"
  java -version
  echo "podman version"
  podman version 
  echo ""	
}	

probando_conexion(){
  echo "*. PROBANDO CONEXION:"
  echo "ping ${vIMAGE_HOST} -c 5" 
  ping ${vIMAGE_HOST} -c 5
  echo "timeout 5 telnet ${vIP_FLOTANTE} ${vPORT_HTTPS}"
  timeout 5 telnet ${vIP_FLOTANTE} ${vPORT_HTTPS}
  echo "- COMANDO: [podman login ${vIMAGE_HOST_ENT_KEY} -u cp -p ${vENTITLEMENT_KEY}]"  
  podman login ${vIMAGE_HOST_ENT_KEY} -u cp -p ${vENTITLEMENT_KEY}
  sleep ${vTIME_SLEEP_02}
  echo "" 	
}	

eliminando_componentes(){
  echo "*. ELIMINANDO COMPONENTES DE CONTENDOR EXISTES:"
  echo "- COMANDO: [podman rm -f ${vID_CONTAINER}]"
  podman rm -f ${vID_CONTAINER}
  sleep ${vTIME_SLEEP_02}
  echo "- COMANDO: [podman rmi -f ${vID_IMAGE}]"  
  podman rmi -f ${vID_IMAGE}  
  echo ""
}	
	
procesando_adicionales(){ 
  echo "*. ACTIVANDO FIREWALL:"
  echo "- COMANDO: [firewall-cmd --add-port=${vPORT_HTTPS}/tcp --permanent --zone=public]"
  echo "- COMANDO: [firewall-cmd --add-port=${vPORT_MQ}/tcp --permanent --zone=public]"
  echo "- COMANDO: [firewall-cmd --add-port=${vPORT_AMQP}/tcp --permanent --zone=public]"
  echo "- COMANDO: [firewall-cmd --reload"  
  firewall-cmd --add-port=${vPORT_HTTPS}/tcp --permanent --zone=public
  firewall-cmd --add-port=${vPORT_MQ}/tcp --permanent --zone=public
  firewall-cmd --add-port=${vPORT_AMQP}/tcp --permanent --zone=public
  firewall-cmd --reload 
  echo ""
}

procesando_componentes(){   
  echo "*. DESCARGANDO IMAGE:" 
  echo "- COMANDO: [podman pull ${vIMAGE_NAME}:${vIMAGE_VERSION}]"
  podman pull ${vIMAGE_NAME}:${vIMAGE_VERSION}  
  echo "- COMANDO: [podman images]"
  podman images
  vID_IMAGE=$(podman images | grep 'ibm-messaging' | head -n 1 | awk '{print $3}')
  echo "- vID_IMAGE: [${vID_IMAGE}]"
  echo ""
  
  echo "*. DESPLEGANDO CONTENEDOR:"
  echo "- COMANDO: [podman run --env LICENSE=accept --env MQ_QMGR_NAME=${vMQ_MQM} --env MQ_APP_PASSWORD=${vMQ_PASSWORD} --env MQ_ADMIN_PASSWORD=${vMQ_PASSWORD} -d --name ${vMQ_CUSTOM_NAME} -p ${vPORT_MQ}:${vPORT_MQ} -p ${vPORT_HTTPS}:${vPORT_HTTPS} -p ${vPORT_AMQP}:${vPORT_AMQP} ${vID_IMAGE} &]"
  podman run --env LICENSE=accept --env MQ_QMGR_NAME=${vMQ_MQM} --env MQ_APP_PASSWORD=${vMQ_PASSWORD} --env MQ_ADMIN_PASSWORD=${vMQ_PASSWORD} -d --name ${vMQ_CUSTOM_NAME} -p ${vPORT_MQ}:${vPORT_MQ} -p ${vPORT_HTTPS}:${vPORT_HTTPS} -p ${vPORT_AMQP}:${vPORT_AMQP} ${vID_IMAGE} &    
  sleep ${vTIME_SLEEP_02}
  echo "- COMANDO: [podman ps -a]"
  podman ps -a
  vID_CONTAINER=$(podman ps -a | grep 'ibm-messaging' | head -n 1 | awk '{print $1}') 
  echo "- vID_CONTAINER: [${vID_CONTAINER}]"
  echo "" 
 
  echo "*. VALIDAR LOGs:"
  echo "- COMANDO: [podman logs ${vID_CONTAINER}]" 
  sleep ${vTIME_SLEEP_01}
  podman logs ${vID_CONTAINER}
  echo ""     
  
  echo "*. VALIDAR URL:"
  echo "- COMANDO: [curl -k https://${vIP_FLOTANTE}:${vPORT_HTTPS}/ibmmq/console/login.html]"  
  curl -k https://${vIP_FLOTANTE}:${vPORT_HTTPS}/ibmmq/console/login.html
  echo ""  
}

#### PROCESAMIENTO DE DATOS: #### 
if [ -z "${vID_IMAGE}" ] || [ -z "${vID_CONTAINER}" ]; then
  echo "NO se encontraron datos de CONTENEDORES."
  echo ""
  probando_dependencias
  probando_conexion  
  procesando_adicionales
  procesando_componentes
  
else
  echo "SI se encontraron datos de CONTENEDORES, los IDs son:"
  echo ""
  probando_dependencias
  probando_conexion
  eliminando_componentes
  procesando_adicionales
  procesando_componentes
     
fi

