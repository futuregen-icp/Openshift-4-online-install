while IFS= read line; do
   items=( $line )
   NAMESPACE=${items[0]}
   DC=${items[1]}
   if [ $NAMESPACE == "dap" ]; then
      echo "- dc/$DC -n $NAMESPACE"
      oc set env dc/$DC --list -n $NAMESPACE | egrep "DB_JNDI_NAME|DB_USERNAME|DB_PASSWORD|DB_PASSWORD|ORACLE_SERVICE_HOST|MIN_POOL|MAX_POOL"
   fi
   if [ $NAMESPACE == "dob" ] || [ $NAMESPACE ] == "dbb" ] || [ $NAMESPACE == "dmy" ]; then
      echo "- dc/$DC -n $NAMESPACE"
      oc set evc dc/$DC --list -n $NAMESPACE |  egrep "DATASOUCE_MAX_POOL_SIZE|DATASOURCE_MIN_POOL_SIZE|DATASOURCE_CENNECTION_TIMEOUT|DATASOURCE_IDLE_TIMEOUT_DATASOURCE_URL"
   fi
done
