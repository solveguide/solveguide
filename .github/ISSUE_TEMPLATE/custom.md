---
name: Custom issue template
about: Generic Work Item Template
title: ''
labels: ''
assignees: solveguide

---

---
name: Generic Work Item
about: Coordinate dev, design & copy
title: "[FEATURE] Brief description of the feature"
labels: feature, needs-triage
assignees: ''
projects: 1

---

### BDD Scenario
```gherkin
Scenario: [Title]
  Given [context]
  And [some more context]...
  When [event]
  Then [outcome]
  And [another outcome]...

## Description
Briefly describe the feature. What problem does it solve?

## User Story
As a [type of user], I want [some goal] so that [some reason].

## Acceptance Criteria
List the requirements or conditions that need to be met:
1. Criterion 1
2. Criterion 2
3. Criterion 3

## Design & Copy Requirements
- [ ] Is there a design requirement for this feature? (yes/no)
- [ ] Is there a copywriting requirement for this feature? (yes/no)

### Design Details
If design is required, add initial design notes here or attach files.

### Copy Details
If copywriting is needed, specify the text or content changes here.