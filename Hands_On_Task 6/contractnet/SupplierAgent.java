package contractnet;

import jade.core.Agent;
import jade.lang.acl.ACLMessage;
import jade.domain.FIPANames;
import jade.lang.acl.MessageTemplate;
import jade.proto.ContractNetResponder;
import jade.domain.FIPAAgentManagement.NotUnderstoodException;
import jade.domain.FIPAAgentManagement.RefuseException;
import jade.domain.FIPAAgentManagement.FailureException;
import java.util.Random;

public class SupplierAgent extends Agent {

    private Random rng = new Random();

    @Override
    protected void setup() {
        // Template: FIPA-CONTRACT-NET protocol & CFP performative
        MessageTemplate mt = MessageTemplate.and(
                MessageTemplate.MatchProtocol(FIPANames.InteractionProtocol.FIPA_CONTRACT_NET),
                MessageTemplate.MatchPerformative(ACLMessage.CFP)
        );

        addBehaviour(new ContractNetResponder(this, mt) {
            // Called upon CFP
            protected ACLMessage handleCfp(ACLMessage cfp) throws RefuseException, FailureException, NotUnderstoodException {
                String task = cfp.getContent();
                System.out.println(getLocalName() + ": Received CFP from " + cfp.getSender().getLocalName()
                        + " -> " + task);

                // Decide whether to propose or refuse (randomly sometimes refuse)
                if (rng.nextDouble() < 0.15) { // 15% chance to refuse
                    System.out.println(getLocalName() + ": Refusing to propose.");
                    throw new RefuseException("Not available");
                }

                // Build a proposal: here random price between 50 and 500
                int price = 50 + rng.nextInt(451);
                ACLMessage propose = cfp.createReply();
                propose.setPerformative(ACLMessage.PROPOSE);
                propose.setContent(String.valueOf(price));
                System.out.println(getLocalName() + ": Sending PROPOSE (price=" + price + ")");
                return propose;
            }

            // Called when the initiator accepts our proposal
            protected ACLMessage handleAcceptProposal(ACLMessage cfp, ACLMessage propose, ACLMessage accept)
                    throws FailureException {
                System.out.println(getLocalName() + ": Proposal accepted by " + accept.getSender().getLocalName()
                        + ". Performing the task...");

                // Simulate work (random short delay); could fail randomly
                try {
                    Thread.sleep(1000 + rng.nextInt(2000));
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    throw new FailureException("interrupted");
                }

                if (rng.nextDouble() < 0.10) { // 10% chance to fail performing
                    System.out.println(getLocalName() + ": Task failed during execution.");
                    throw new FailureException("Execution error");
                }

                ACLMessage inform = accept.createReply();
                inform.setPerformative(ACLMessage.INFORM);
                inform.setContent("done;price=" + propose.getContent());
                System.out.println(getLocalName() + ": Task completed successfully. Sending INFORM.");
                return inform;
            }

            // Called when our proposal was rejected
            protected void handleRejectProposal(ACLMessage cfp, ACLMessage propose, ACLMessage reject) {
                System.out.println(getLocalName() + ": Proposal rejected by " + reject.getSender().getLocalName());
            }
        });
    }
}
