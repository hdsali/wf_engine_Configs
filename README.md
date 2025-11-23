pull the image from : hdsali/wf_engine:latest
Short Intro 

Workflow Engine is a lightweight, flexible process automation framework that lets you design, run, and monitor business workflows — without hardcoding process logic.
It empowers your applications (like EDMS or Document Approval systems) to automate multi-step approval flows, enforce company-specific rules, and track progress transparently from start to finish


WorkFlow Engine features:
1. Dynamic Workflow Definitions

Define any business process — e.g., Document Approval, Transmittal Review, Purchase Request,... — through a configurable workflow model.

Each workflow consists of states, transitions, and conditions that describe how work moves forward.

Fully database-driven: you can update or add new workflows without redeploying code.

2. Workflow Execution Engine

Built-in services (StartWorkflowUseCase, MoveToNextStateUseCase) execute the defined workflows.

Supports:

	Automatic state transitions

	Conditional routing

	User-driven approval or rejection steps

	Integrates easily into APIs and microservices.

3. Event-Driven Architecture

  Includes a clean event dispatcher system.

  Triggers domain events like:

	WorkflowStateEnteredEvent

	WorkflowCompletedEvent

   Easy to hook custom logic such as:

	system notifications
	Auditing workflow progress

4. Company-Specific Business Rules

   Supports field-level customization per company and workflow (like your EntityFieldConfig model).

   Example:

	Company A needs DocumentNumber, Title, Description, Date as required Fields

	Company B only needs DocumentNumber, Date as required field

  Makes multi-tenant systems (like EDMS or DocumentApproval SaaS) easily configurable for each customer.

5. Auditing & History Tracking

  Every state change and transition is automatically logged.

  Provides workflow history endpoints for audit trails and compliance.

  Perfect for enterprise document control and regulated environments.

6. Modular Architecture

  Cleanly separated layers:

  	Domain – core workflow logic

  	Application – use cases (start, transition, notify)

  	Infrastructure – EF Core repositories, persistence, seeding

  	Web – RESTful endpoints

  Easy to embed into other solutions (like your DocumentApproval project).
7. Tech Stack & Integration

   Built with .NET 8, Entity Framework Core, and SQL Server

   Deployable as:

	A standalone API service

	Or embedded directly into another .NET solution

   Provides simple REST endpoints for workflow creation, progression, and history queries.

Example Use Cases
	System	  	        	Workflow Example	 		Description
	EDMS / Transmittal		Transmittal Review Flow			Document → Checked → Approved → Sent to Client
	Document Approval System	Multi-level Approval			Draft → Manager Review → Quality Control → Final
	HR / Onboarding			New Hire Process			HR Review → IT Setup → Manager Approval
	Procurement System		Purchase Order Flow			Request → Budget Review → Vendor Approval

-Workflow state → Event/Command Each workflow state emits an event or command, e.g., ManagerApprovalNeeded. CommandHandler reacts to event Your handler picks it up and executes the business logic. This decouples workflow from code and keeps the engine flexible.

-defining WF Instance per WF usageClient e.g per Company
-workflow parameterization
