package contractnet;

import jade.core.Agent;
import jade.core.AID;
import jade.lang.acl.ACLMessage;
import jade.domain.FIPANames;
import jade.proto.ContractNetInitiator;
import java.util.Vector;
import java.util.Enumeration;
import java.util.Date;

public class InitiatorAgent extends Agent {

    @Override
    protected void setup() {
        Object[] args = getArguments();
        String[] receivers;
        if (args != null && args.length > 0) {
            receivers = new String[args.length];
            for (int i = 0; i < args.length; i++) {
                receivers[i] = args[i].toString();
            }
        } else {
            // defaults if none passed
            receivers = new String[] {"supplier1", "supplier2"};
        }

        // Prepare CFP message
        ACLMessage cfp = new ACLMessage(ACLMessage.CFP);
        for (String r : receivers) {
            cfp.addReceiver(new AID(r, AID.ISLOCALNAME));
        }
        cfp.setProtocol(FIPANames.InteractionProtocol.FIPA_CONTRACT_NET);
        cfp.setReplyByDate(new Date(System.currentTimeMillis() + 10000)); // 10s
        cfp.setContent("task=compute;workload=1000"); // arbitrary task description

        addBehaviour(new ContractNetInitiator(this, cfp) {
            // Called when a PROPOSE message arrives
            protected void handlePropose(ACLMessage propose, Vector acceptances) {
                System.out.println(getLocalName() + ": Received PROPOSE from " + propose.getSender().getLocalName()
                        + " -> " + propose.getContent());
            }

            // Called when a REFUSE arrives
            protected void handleRefuse(ACLMessage refuse) {
                System.out.println(getLocalName() + ": Received REFUSE from " + refuse.getSender().getLocalName());
            }

            // Called when all responses are received or timeout occurs.
            // The 'responses' Vector contains the received messages from participants (propose/refuse).
            // We must fill 'acceptances' Vector with the replies (ACCEPT_PROPOSAL / REJECT_PROPOSAL).
            protected void handleAllResponses(Vector responses, Vector acceptances) {
                System.out.println(getLocalName() + ": Handling all responses (" + responses.size() + ")");

                if (responses.size() == 0) {
                    System.out.println(getLocalName() + ": No responses - giving up.");
                    return;
                }

                // Choose best proposal (here: minimum price given as content)
                int bestPrice = Integer.MAX_VALUE;
                ACLMessage bestProposal = null;
                Enumeration e = responses.elements();
                while (e.hasMoreElements()) {
                    ACLMessage msg = (ACLMessage) e.nextElement();
                    if (msg.getPerformative() == ACLMessage.PROPOSE) {
                        try {
                            int price = Integer.parseInt(msg.getContent());
                            if (price < bestPrice) {
                                bestPrice = price;
                                bestProposal = msg;
                            }
                        } catch (NumberFormatException ex) {
                            // malformed proposal content; skip
                        }
                    }
                }

                // create accept/reject replies corresponding to each response
                e = responses.elements();
                while (e.hasMoreElements()) {
                    ACLMessage msg = (ACLMessage) e.nextElement();
                    ACLMessage reply = msg.createReply();
                    if (msg == bestProposal) {
                        reply.setPerformative(ACLMessage.ACCEPT_PROPOSAL);
                        reply.setContent("accepted");
                        System.out.println(getLocalName() + ": Accepting proposal from " + msg.getSender().getLocalName()
                                + " (price=" + bestPrice + ")");
                    } else {
                        reply.setPerformative(ACLMessage.REJECT_PROPOSAL);
                        reply.setContent("rejected");
                        System.out.println(getLocalName() + ": Rejecting proposal from " + msg.getSender().getLocalName()
                                + " (content=" + msg.getContent() + ")");
                    }
                    acceptances.add(reply);
                }
            }

            // Called when an inform is received from an accepted agent (successful execution)
            protected void handleInform(ACLMessage inform) {
                System.out.println(getLocalName() + ": Agent " + inform.getSender().getLocalName()
                        + " successfully performed the task. Content: " + inform.getContent());
            }

            // Called if an accepted agent failed to perform the task
            protected void handleFailure(ACLMessage failure) {
                System.out.println(getLocalName() + ": Agent " + failure.getSender().getLocalName()
                        + " failed to perform the task.");
            }
        });
    }
}
