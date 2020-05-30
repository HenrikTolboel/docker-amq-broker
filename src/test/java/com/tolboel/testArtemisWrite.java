package com.tolboel.artemis;


import org.apache.activemq.artemis.jms.client.ActiveMQConnectionFactory;

import javax.jms.*;

public class testArtemisWrite {

    public static void main(String[] args) throws Exception {

        ActiveMQConnectionFactory activeMQConnectionFactory =
                new ActiveMQConnectionFactory("tcp://localhost:61616", "admin", "admin");

        Connection connection = activeMQConnectionFactory.createConnection();

        Session session = connection.createSession();

        Queue queue = session.createQueue("incoming");
        MessageProducer producer = session.createProducer(queue);

        TextMessage message = session.createTextMessage("test message");

        producer.send(message);
        producer.send(message);
        producer.send(message);
        producer.send(message);

        producer.close();

        session.close();

        connection.close();
    }
}
