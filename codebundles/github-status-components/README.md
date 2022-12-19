# GitHub Status - Platform Components

## SLI - Component Availability 
Check status of the GitHub platform (https://www.githubstatus.com/) for a specified set of GitHub service components.
The metric supplied is a aggregated percentage indicating the availability of the components with 1 = 100% available. 

### SLI Metric Calculation Details
> **NOTE:** See the [RW GitHub Status Library](../../libraries/RW/GitHub/Status.py) code for additional details. 

        This SLI calculates an availability metric for the GitHub platform, between 0 and 1.
        Optionally takes a subset of components from which to calculate this total.

        When no components are provided, the score is mapped from the indicator on the
        GitHub status page using the following values:
        - ``none`` : 1
        - ``minor`` : 0.66
        - ``major`` : 0.33
        - ``critical`` : 0

        If the components are provided, this function provides the average component
        availability score of the number of components provided in the set. These
        values are mapped from the component status attribute as follows:
        - ``operational`` : 1
        - ``degraded_performance`` : 0.66
        - ``partial_outage`` : 0.33
        - ``major_outage`` : 0

        Parameters:
            components (Set[str]): Set of components to optionally calculate
            availability score from. Current possible values at time of this release
            are:
                - "Git Operations"
                - "API Requests"
                - "Webhooks"
                - "Issues"
                - "Pull Requests"
                - "Actions"
                - "Packages"
                - "Pages"
                - "Codespaces"
                - "Copilot"

        Raises:
            ValueError: If the components provided do not match the list fetched from
            GitHub

        Returns:
            Value between 0 and 1 corresponding to the availability of the GitHub
            platform

## Use Cases

## Requirements

## TODO
- [ ] Add additional documentation