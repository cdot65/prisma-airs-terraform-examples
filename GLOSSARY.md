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

**Gateway integration**:
An organization connection to an upstream model service, with the authentication and settings needed to access that service.
_Avoid_: Gateway provider; Terraform provider

**Gateway provider**:
A workspace connection to a model service through a Gateway integration.
_Avoid_: Gateway integration; Terraform provider

**Integration workspace binding**:
The authorization for a particular workspace to access a particular organization integration.
_Avoid_: Gateway provider

**Gateway routing configuration**:
A saved policy governing model request routing, retries, caching, and guardrail inspection.
_Avoid_: Security profile

**Workspace guardrail**:
A request or response inspection policy used by applications within a Gateway workspace.
_Avoid_: Organization guardrail

**Organization guardrail**:
A Gateway inspection policy establishing an organization-wide baseline across workspaces.
_Avoid_: Workspace guardrail

**Gateway service API key**:
A credential through which an application receives authorized access to Gateway capabilities and default request settings.
_Avoid_: Upstream model credential; Runtime Security API key

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

**Gateway MCP integration**:
An organization connection to an external MCP tool service.
_Avoid_: Workspace MCP server

**Workspace MCP server**:
The workspace's access point for an authorized Gateway MCP integration.
_Avoid_: Gateway MCP integration; upstream MCP service

**Gateway deployment registration**:
The control-plane record describing a Gateway deployment and its connection settings.
_Avoid_: Running gateway instance; installed gateway infrastructure
