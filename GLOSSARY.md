# Prisma AIRS Configuration

Product vocabulary for the environments illustrated by these examples.

## Language

**AI Runtime Security**:
The product that protects AI applications during use through policies and content inspection.
_Avoid_: Management (a function within the product)

**AI Red Teaming**:
The product that evaluates applications, agents and models through adversarial testing.
_Avoid_: Runtime Security

**AI Gateway**:
The product that governs access to model providers through routing, integrations and request controls.
_Avoid_: Red Team target connection; Network Broker channel

**AI Supply Chain Security**:
The product concerned with the security of AI models and artifacts throughout their supply chain.
_Avoid_: Model Security (when referring to the whole product)

**Model Security**:
The model-focused capability within AI Supply Chain Security.
_Avoid_: AI Supply Chain Security (when referring only to model-focused capabilities)

**Skill Scanning**:
The Supply Chain Security capability that assesses agent skills and records findings, policy decisions and fingerprint-specific trust.
_Avoid_: AgentGuard (when naming the product capability)

**Security profile**:
A named Runtime Security policy with one or more revisions.
_Avoid_: Security profile revision (one particular version)

**Red Team target**:
An application, agent or model registered as a subject of adversarial testing.
_Avoid_: Customer app; Network Broker channel

**Custom prompt set**:
A named collection of custom attack prompts for AI Red Teaming.
_Avoid_: Custom prompt (one member of the collection)

**Trusted-skill override**:
A trust decision for one exact skill fingerprint.
_Avoid_: Tenant-wide rule; blanket approval of a skill name
