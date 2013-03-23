
Examples of concerns that tend to be crosscutting include:

Synchronization -- (declare an action dependency, trigger, event)
Real-time constraints
Feature interaction
Memory management
  - data checks
  - feature checks
* security
  - firewall rules
  - access control
Logging
Monitoring
Business rules
Tuning 
Refactor pivot


AOP:

- Scattered (1:n) / Tangled (n:1) 
- join point: hook
- point cut: matches join points
- advice: behavior evoked at point cut

* Interception
  - Interjection of advice, at least around methods.
* Introduction
  - Enhancing with new (orthogonal!) state and behavior .
* Inspection
  - Access to meta-information that may be exploited by pointcuts or
advice.
* Modularization
  - Encapsulate as aspects.

