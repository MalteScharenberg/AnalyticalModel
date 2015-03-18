function ChannelStateMachine()
%CHANNELSTATEMACHINE Summary of this function goes here
%   Detailed explanation goes here

% initialise nodes
minNodeNumber = 1;
maxNodeNumber = 5;
packetNumber = 100;

throughput(maxNodeNumber) = 0;
delay(maxNodeNumber) = 0;

for nNodes = minNodeNumber:maxNodeNumber
    fprintf('\nCalculating mean throughput of %d nodes...\n\n', nNodes)
    
    % preallocate memory with empty constructor
    clear nodes;
    nodeList(1,nNodes) = NodeFiniteStateMachine(); %#ok<AGROW>
    for n=1:nNodes
        nodeList(n) = NodeFiniteStateMachine();
        nodeList(n).sendPackage(100,4);
    end
    
    run = true;
    % results(nodeNumber, packageNumber, 2) = 0;
    slots = 0;
    while run
        slots = slots + 1;
        channelState = 'clear';
        
        throughputSum = 0;
        delaySum = 0;
        ccaFailureSum = 0;
        for node = nodeList
            if strcmp(node.getState(), 'transmission')
                channelState = 'busy';
            end
            % Stop if all nodes are idle
            run = false;
            
            throughputSum = throughputSum + node.getThroughput();
            delaySum = delaySum + node.getDelay();
            ccaFailureSum = ccaFailureSum + node.getNotSend();
            
            if ~strcmp(node.getState(), 'idle')
                run = true;
            end
        end
        
        for n = 1:nNodes
            nodeList(n).nextStep(channelState);
            if strcmp(nodeList(n).getState(), 'idle')
                packetsSend = nodeList(n).getSend() + nodeList(n).getNotSend();
                if packetsSend <= packetNumber
                    % results(n, packagesSend, 1) = slots * 0.000016;
                    % results(n, packagesSend, 2) = nodes(n).getThroughput();
                    % nodes(n).reset();
                    nodeList(n).sendPacket(100,4);
                end
            end
        end
        
        % Make CLI Ouput after round
        if ~run
            throughput(nNodes) = (throughputSum / nNodes) /  1000;
            delay(nNodes) = delaySum / nNodes;
            fprintf('CCA Failure sum: %d\n', ccaFailureSum)
            fprintf('Throughput mean: %f\n', throughput(nNodes))
            fprintf('Delay mean: %f\n', delay(nNodes))
        end
    end
end
%    colorstring = 'kbgry';
%     for n = 1:nodeNumber
%         plot(results(n,:,1), results(n,:,2), colorstring(n)); hold on;
%     end
plot(1:maxNodeNumber, throughput);
xlabel('Number of nodes')
ylabel('mean throughput of all nodes [kbits]')
end

