import json
import stomp
import logging
import socket
import sys
import time

logging.basicConfig(stream=sys.stdout, level=logging.INFO)


class MessagingListener(stomp.ConnectionListener):
    '''
    Messaging Listener
    '''
    def __init__(self, broker):
        '''
        __init__
        '''
        self.__broker = broker
        self.logger = logging.getLogger(self.__class__.__name__)

    def on_error(self, frame):
        '''
        Error handler
        '''
        self.logger.error('[broker] [%s]: %s' % (self.__broker, frame))

    def on_message(self, frame):
        self.logger.info("received message: %s" % str(frame))


class Receiver(stomp.ConnectionListener):
    def __init__(self, broker):
        '''
        __init__
        '''
        self.__broker = broker
        self.logger = logging.getLogger(self.__class__.__name__)

    def on_error(self, frame):
        '''
        Error handler
        '''
        self.logger.error('[broker] [%s]: %s', self.__broker, frame)
    def on_message(self, frame):
        body = frame
        print("received message: %s", body)
        self.logger.info("received message: %s", body)
        print(type(body))
        body = json.loads(body.body)
        if 'msg_type' in body and body['msg_type'] == 'health_heartbeat':
            self.logger.info("received message: %s", body)

if True:
    # It's an internal ip of k8s.
    # To test it, user can login a pod which can communicate with activemq,
    # for example "kubectl exec -it idds-dev-main-daemon-fd58d9d67-n558p -- bash"
    broker = '10.102.232.81'     # get the k8s ClusterIP for service 'activemq-dev-main'
    receiver_port = 61613
    port = 61613
    topic = '/topic/pandaidds'
    receive_topics = ['/topic/pandaidds']
    username = 'idds'
    password = 'MyPass0508'

addrinfos = socket.getaddrinfo(broker, 0, socket.AF_INET, 0, socket.IPPROTO_TCP)
brokers_resolved = [ai[4][0] for ai in addrinfos]

for broker in brokers_resolved:
    conn = stomp.Connection12(host_and_ports=[(broker, port)], keepalive=True)
    conn.set_listener('message-sender', MessagingListener(conn.transport._Transport__host_and_ports[0]))

    # conn.start()
    conn.connect(username, password, wait=True)

    payload = {"files": [{"adler32": "0cc737eb", "scope": "mock", "bytes": 1, "name": "file_ac6db48094974e039aa9d1ae52873596"}], "rse": "WJ-XROOTD", "operation": "add_replicas", "lifetime": 2}

    print("sending message")
    try:
        for i in range(10):
            conn.send(destination=topic, body=json.dumps(payload), id='atlas-idds-messaging', ack='auto', headers={'persistent': 'true', 'vo': 'atlas'})
            pass
    except Exception as ex:
        print(ex)


    # time.sleep(10)
    print("sent message")


    for receive_topic in receive_topics:
        print('start receiver: %s' % receive_topic)
        conn = stomp.Connection12(host_and_ports=[(broker, receiver_port)], keepalive=True)
        conn.set_listener('message-receiver', Receiver(conn.transport._Transport__host_and_ports[0]))

        # conn.start()
        conn.connect(username, password, wait=True)
        conn.subscribe(destination=receive_topic, id='atlas-idds-messaging', ack='auto')
time.sleep(1000)
