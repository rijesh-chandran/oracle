EXECUTE DBMS_AQADM.CREATE_QUEUE_TABLE (
queue_table        => 'kort.test_qt',
multiple_consumers => TRUE, 
queue_payload_type => 'KORT.DB_EVENT_MESSAGE_OT');

EXECUTE DBMS_AQADM.CREATE_QUEUE (
queue_name         => 'test_q',
queue_table        => 'kort.test_qt');

EXECUTE DBMS_AQADM.START_QUEUE (
queue_name         => 'test_q');

Creating a Queue to Demonstrate Propagation
EXECUTE DBMS_AQADM.CREATE_QUEUE (
queue_name        => 'another_msg_queue',
queue_table       => 'aq.MultiConsumerMsgs_qtab');

EXECUTE DBMS_AQADM.START_QUEUE (
queue_name         => 'another_msg_queue');


DECLARE
   enqueue_options     DBMS_AQ.enqueue_options_t;
   message_properties  DBMS_AQ.message_properties_t;
   recipients          DBMS_AQ.aq$_recipient_list_t;
   message_handle      RAW(16);
   message             KORT.DB_EVENT_MESSAGE_OT;
BEGIN
   SELECT USER_DATA INTO msg FROM KORT.AQ$EVENT_ENGINE_QT_BKP WHERE rownum=1;

   recipients(1) := aq$_agent('EH_KAFKA', NULL, NULL);
   recipients(2) := aq$_agent('EH_PYMTHUB', NULL, NULL);
   message_properties.recipient_list := recipients;

   DBMS_AQ.ENQUEUE(queue_name => 'test_q',
           enqueue_options    => enqueue_options,
           message_properties => message_properties,
           payload            => message,
           msgid              => message_handle);
END;
/

.
TEAMS MEETING SUMMARY
=====================

Joined Teams Meeting with customer. 

- Customer had to purge the queue table because of some ORA-00600 errors. Before purging they backed up the queue table view KORT.AQ$EVENT_ENGINE_QT into a table as "KORT.AQ$EVENT_ENGINE_QT_BKP"

- Now they are looking to get back the messages which are purged. Below are the messages in the backup table. 

SQ> SELECT msg_state, consumer_name, count(*) FROM KORT.AQ$EVENT_ENGINE_QT_BKP GROUP BY msg_state, consumer_name ORDER BY 2,1;

MSG_STATE        CONSUMER_NAME                              COUNT(*)
---------------- ---------------------------------------- ----------
PROCESSED        EH_AUTH_INFO                                 209278
READY            EH_AUTH_INFO                                      1
WAIT             EH_AUTH_INFO                                   9383
PROCESSED        EH_ENG_INFO                                   16214
UNDELIVERABLE    EH_ENG_INFO                                     774
WAIT             EH_ENG_INFO                                     162
PROCESSED        EH_FDD_DE                                         1
WAIT             EH_FDD_DE                                      1575
PROCESSED        EH_GANSTLV_OUT_DE                            199351
READY            EH_GANSTLV_OUT_DE                                 1
WAIT             EH_GANSTLV_OUT_DE                              9383
PROCESSED        EH_KAFKA                                     338469
PROCESSED        EH_MLTF_DE                                    47238
UNDELIVERABLE    EH_MLTF_DE                                      774
WAIT             EH_MLTF_DE                                      162
PROCESSED        EH_PYMTHUB                                    15508
WAIT             EH_PYMTHUB                                       19
PROCESSED        EH_SEPA_MANDATE                               11671
WAIT             EH_SEPA_MANDATE                                 207

- I have informed them that the messages which are in PROCESSED status is already consumed by their subscribers (consumers). 
- They need to check with their developer about which consumers they are interested in from the backup table 
- The list of default queue subscribers/consumers are below:

SQL> select subscriber_id, name from KORT.AQ$_EVENT_ENGINE_QT_S;
 
SUBSCRIBER_ID NAME
------------- ------------------------------
            0
            2
           21
           83 EH_KAFKA
           62 EH_MLTF_DE
           63 EH_AUTH_INFO
           64 EH_ENG_INFO
           65 EH_SEPA_MANDATE
           66 EH_SCA_DE
           67 EH_FDD_DE
           68 EH_GANSTLV_OUT_DE
           84 EH_PYMTHUB

- I have shown them how to process the messages from the backup table which are not in PROCESSED state.
- We created a sample test queue table and queue (TEST_QT and TEST_Q) and tried to enqueue the messages that are not in PROCESSED state 
- This procedure worked fine for us and they can use a similar procedure and decide if they want to extract the unprocessed messages from the queue and enqueue them back to the original queue 
- Since I do not understand the effects of re-enqueuing the messages back to the original queue, their developers will need to look into this
- I helped Nikita to create a sample PL/SQL code to extract the messages from KORT.AQ$EVENT_ENGINE_QT_BKP and enqueue them into TEST_Q and this worked fine 
- Nikita will work with the developer to extract the messages in the queue 


DECLARE
   enqueue_options     DBMS_AQ.enqueue_options_t;
   message_properties  DBMS_AQ.message_properties_t;
   recipients          DBMS_AQ.aq$_recipient_list_t;
   message_handle      RAW(16);
   message             KORT.DB_EVENT_MESSAGE_OT;
   indx                INTEGER;
BEGIN	
	FOR i IN (SELECT msg_id,count(*) FROM KORT.AQ$EVENT_ENGINE_QT_BKP WHERE msg_state!='PROCESSED' GROUP BY msg_id ORDER BY 2) 
	LOOP
		indx := 1;
		FOR j IN (SELECT consumer_name FROM KORT.AQ$EVENT_ENGINE_QT_BKP WHERE msg_id=i.msg_id)
		LOOP 
			recipients(indx) := aq$_agent(j.consumer_name, NULL, NULL);
			indx := indx + 1;
		END LOOP;
		SELECT user_data INTO message FROM KORT.AQ$EVENT_ENGINE_QT_BKP WHERE msg_id=i.msg_id and rownum<2;	
		message_properties.recipient_list := recipients;
	    DBMS_AQ.ENQUEUE(queue_name => 'KORT.TEST_Q',
           enqueue_options    => enqueue_options,
           message_properties => message_properties,
           payload            => message,
           msgid              => message_handle);	
		COMMIT; 
	END LOOP;	
END;
/




30064704 