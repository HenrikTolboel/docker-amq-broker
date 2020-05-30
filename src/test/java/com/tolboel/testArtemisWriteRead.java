package com.tolboel.artemis;


import org.apache.activemq.artemis.jms.client.ActiveMQConnectionFactory;
import org.apache.camel.CamelContext;
import org.apache.camel.Exchange;
import org.apache.camel.Processor;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.jms.JmsComponent;
import org.apache.camel.impl.DefaultCamelContext;

import javax.jms.*;

public class testArtemisWriteRead {

    public static void main(String[] args) throws Exception {
        CamelContext camelContext = new DefaultCamelContext();

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

        camelContext.addComponent("jms",
                JmsComponent.jmsComponentAutoAcknowledge(activeMQConnectionFactory));


        camelContext.addRoutes(new RouteBuilder() {
            public void configure() {
                from("jms:incoming").
                        process(new Processor() {
                            @Override
                            public void process(Exchange exchange) throws Exception {
                                System.out.println("jms:incoming: " +
                                        exchange.getIn().getHeader("CamelFileName") +
                                        ", tenantIdentifier: " +
                                        exchange.getIn().getHeader("tenantIdentifier") +
                                        ", body: " +
                                        exchange.getIn().getBody().toString());
                            }
                        });
            }
        });

        camelContext.start();

        Thread.sleep(1000);
    }
}
