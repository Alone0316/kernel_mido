#
# Common parameter parsing for pktgen scripts
#

function usage() {
    echo ""
    echo "Usage: $0 [-vx] -i ethX"
    echo "  -i : (\$DEV)       output interface/device (required)"
    echo "  -s : (\$PKT_SIZE)  packet size"
    echo "  -d : (\$DEST_IP)   destination IP"
    echo "  -m : (\$DST_MAC)   destination MAC-addr"
    echo "  -k : (\$UDP_CSUM)  enable UDP tx checksum"
    echo "  -t : (\$THREADS)   threads to start"
    echo "  -c : (\$SKB_CLONE) SKB clones send before alloc new SKB"
    echo "  -b : (\$BURST)     HW level bursting of SKBs"
    echo "  -v : (\$VERBOSE)   verbose"
    echo "  -x : (\$DEBUG)     debug"
    echo "  -6 : (\$IP6)       IPv6"
    echo "  -w : (\$DELAY)     Tx Delay value (ns)"
    echo "  -a : (\$APPEND)    Script will not reset generator's state, but will append its config"
    echo ""
}

##  --- Parse command line arguments / parameters ---
## echo "Commandline options:"
while getopts "s:i:d:m:t:c:b:w:vxh6ak" option; do
    case $option in
        i) # interface
          export DEV=$OPTARG
	  info "Output device set to: DEV=$DEV"
          ;;
        s)
          export PKT_SIZE=$OPTARG
	  info "Packet size set to: PKT_SIZE=$PKT_SIZE bytes"
          ;;
        d) # destination IP
          export DEST_IP=$OPTARG
	  info "Destination IP set to: DEST_IP=$DEST_IP"
          ;;
        m) # MAC
          export DST_MAC=$OPTARG
	  info "Destination MAC set to: DST_MAC=$DST_MAC"
          ;;
        t)
	  export THREADS=$OPTARG
          export CPU_THREADS=$OPTARG
	  let "CPU_THREADS -= 1"
	  info "Number of threads to start: $THREADS (0 to $CPU_THREADS)"
          ;;
        c)
	  export CLONE_SKB=$OPTARG
	  info "CLONE_SKB=$CLONE_SKB"
          ;;
        b)
	  export BURST=$OPTARG
	  info "SKB bursting: BURST=$BURST"
          ;;
        w)
	  export DELAY=$OPTARG
	  info "DELAY=$DELAY"
          ;;
        v)
          export VERBOSE=yes
          info "Verbose mode: VERBOSE=$VERBOSE"
          ;;
        x)
          export DEBUG=yes
          info "Debug mode: DEBUG=$DEBUG"
          ;;
	6)
	  export IP6=6
	  info "IP6: IP6=$IP6"
	  ;;
        a)
          export APPEND=yes
          info "Append mode: APPEND=$APPEND"
          ;;
        k)
          export UDP_CSUM=yes
          info "UDP tx checksum: UDP_CSUM=$UDP_CSUM"
          ;;
        h|?|*)
          usage;
          err 2 "[ERROR] Unknown parameters!!!"
    esac
done
shift $(( $OPTIND - 1 ))

if [ -z "$PKT_SIZE" ]; then
    # NIC adds 4 bytes CRC
    export PKT_SIZE=60
    info "Default packet size set to: set to: $PKT_SIZE bytes"
fi

if [ -z "$THREADS" ]; then
    # Zero CPU threads means one thread, because CPU numbers are zero indexed
    export CPU_THREADS=0
    export THREADS=1
fi

# default DELAY
[ -z "$DELAY" ] && export DELAY=0 # Zero means max speed

if [ -z "$DEV" ]; then
    usage
    err 2 "Please specify output device"
fi

if [ -z "$DST_MAC" ]; then
    warn "Missing destination MAC address"
fi

if [ -z "$DEST_IP" ]; then
    warn "Missing destination IP address"
fi

if [ ! -d /proc/net/pktgen ]; then
    info "Loading kernel module: pktgen"
    modprobe pktgen
fi
