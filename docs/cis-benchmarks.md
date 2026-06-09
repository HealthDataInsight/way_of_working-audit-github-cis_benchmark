# CIS Benchmarks: GitHub

## Source Code

### Code Changes

- [ ] Ensure any changes to code are tracked in a version control platform (Manual)
- [ ] Ensure any change to code can be traced back to its associated task (Manual) [L1]
- [ ] Ensure any change to code receives approval of two strongly authenticated users (Automated) [L1]
- [x] Ensure previous approvals are dismissed when updates are introduced to a code change proposal (Manual) [L1]
- [ ] Ensure there are restrictions on who can dismiss code change reviews (Manual)
- [ ] Ensure code owners are set for extra sensitive code or configuration (Manual)
- [ ] Ensure code owner's review is required when a change affects owned code (Manual)
- [ ] Ensure inactive branches are periodically reviewed and removed (Manual)
- [ ] Ensure all checks have passed before merging new code (Manual)
- [ ] Ensure open Git branches are up to date before they can be merged into code base (Manual)
- [ ] Ensure all open comments are resolved before allowing code change merging (Manual)
- [ ] Ensure verification of signed commits for new changes before merging (Manual)
- [ ] Ensure linear history is required (Manual)
- [ ] Ensure branch protection rules are enforced for administrators (Manual)
- [ ] Ensure pushing or merging of new code is restricted to specific individuals or teams (Manual)
- [x] Ensure force push code to branches is denied (Manual)
- [x] Ensure branch deletions are denied (Manual)
- [ ] Ensure any merging of code is automatically scanned for risks (Manual)
- [ ] Ensure any changes to branch protection rules are audited (Manual)
- [x] Ensure branch protection is enforced on the default branch (Manual)

### Repository Management

- [x] Ensure all public repositories contain a SECURITY.md file (Manual)
- [ ] Ensure repository creation is limited to specific members (Manual)
- [ ] Ensure repository deletion is limited to specific users (Manual)
- [ ] Ensure issue deletion is limited to specific users (Manual)
- [ ] Ensure all copies (forks) of code are tracked and accounted for (Manual)
- [ ] Ensure all code projects are tracked for changes in visibility status (Manual)
- [ ] Ensure inactive repositories are reviewed and archived periodically (Manual)

### Contribution Access

- [ ] Ensure inactive users are reviewed and removed periodically (Manual)
- [ ] Ensure team creation is limited to specific members (Manual)
- [ ] Ensure minimum number of administrators are set for the organization (Manual)
- [ ] Ensure Multi-Factor Authentication (MFA) is required for contributors of new code (Manual)
- [ ] Ensure the organization is requiring members to use Multi-Factor Authentication (MFA) (Manual)
- [ ] Ensure new members are required to be invited using company-approved email (Manual)
- [ ] Ensure two administrators are set for each repository (Manual)
- [ ] Ensure strict base permissions are set for repositories (Manual)
- [ ] Ensure an organization’s identity is confirmed with a “Verified” badge (Manual)
- [ ] Ensure Source Code Management (SCM) email notifications are restricted to verified domains (Manual)
- [ ] Ensure an organization provides SSH certificates (Manual)
- [ ] Ensure Git access is limited based on IP addresses (Manual)
- [ ] Ensure anomalous code behavior is tracked (Manual)

### Third-Party

- [ ] Ensure administrator approval is required for every installed application (Manual)
- [ ] Ensure stale applications are reviewed and inactive ones are removed (Manual)
- [ ] Ensure the access granted to each installed application is limited to the least privilege needed (Manual)
- [ ] Ensure only secured webhooks are used (Manual)

### Code Risks

- [ ] Ensure scanners are in place to identify and prevent sensitive data in code (Manual)
- [ ] Ensure scanners are in place to secure Continuous Integration (CI) pipeline instructions (Manual)
- [ ] Ensure scanners are in place to secure Infrastructure as Code (IaC) instructions (Manual)
- [ ] Ensure scanners are in place for code vulnerabilities (Manual)
- [ ] Ensure scanners are in place for open-source vulnerabilities in used packages (Manual)
- [ ] Ensure scanners are in place for open-source license issues in used packages (Manual)

## Build Pipelines

### Build Environment

- [ ] Ensure each pipeline has a single responsibility (Manual)
- [ ] Ensure all aspects of the pipeline infrastructure and configuration are immutable (Manual)
- [ ] Ensure the build environment is logged (Manual)
- [ ] Ensure the creation of the build environment is automated (Manual)
- [ ] Ensure access to build environments is limited (Manual)
- [ ] Ensure users must authenticate to access the build environment (Manual)
- [ ] Ensure build secrets are limited to the minimal necessary scope (Manual)
- [ ] Ensure the build infrastructure is automatically scanned for vulnerabilities (Manual)
- [ ] Ensure default passwords are not used (Manual)
- [ ] Ensure webhooks of the build environment are secured (Manual)
- [ ] Ensure minimum number of administrators are set for the build environment (Manual)

### Build Worker

- [ ] Ensure build workers are single-used (Manual)
- [ ] Ensure build worker environments and commands are passed and not pulled (Manual)
- [ ] Ensure the duties of each build worker are segregated (Manual)
- [ ] Ensure build workers have minimal network connectivity (Manual)
- [ ] Ensure run-time security is enforced for build workers (Manual)
- [ ] Ensure build workers are automatically scanned for vulnerabilities (Manual)
- [ ] Ensure build workers' deployment configuration is stored in a version control platform (Manual)
- [ ] Ensure resource consumption of build workers is monitored (Manual)

### Pipeline Instructions

- [ ] Ensure all build steps are defined as code (Manual)
- [ ] Ensure steps have well-defined build stage input and output (Manual)
- [ ] Ensure output is written to a separate, secured storage repository (Manual)
- [ ] Ensure changes to pipeline files are tracked and reviewed (Manual)
- [ ] Ensure access to build process triggering is minimized (Manual)
- [ ] Ensure pipelines are automatically scanned for misconfigurations (Manual)
- [ ] Ensure pipelines are automatically scanned for vulnerabilities (Manual)
- [ ] Ensure scanners are in place to identify and prevent sensitive data in pipeline files (Automated)

### Pipeline Integrity

- [ ] Ensure all artifacts on all releases are signed (Manual)
- [ ] Ensure all external dependencies used in the build process are locked (Manual)
- [ ] Ensure dependencies are validated before being used (Manual)
- [ ] Ensure the build pipeline creates reproducible artifacts (Manual)
- [ ] Ensure pipeline steps produce a Software Bill of Materials (SBOM) (Manual)
- [ ] Ensure pipeline steps sign the Software Bill of Materials (SBOM) produced (Manual)

## Dependencies

### Third-Party Packages

- [ ] Ensure third-party artifacts and open-source libraries are verified (Manual)
- [ ] Ensure Software Bill of Materials (SBOM) is required from all third-party suppliers (Manual)
- [ ] Ensure signed metadata of the build process is required and verified (Manual)
- [ ] Ensure dependencies are monitored between open-source components (Manual)
- [ ] Ensure trusted package managers and repositories are defined and prioritized (Manual)
- [ ] Ensure a signed Software Bill of Materials (SBOM) of the code is supplied (Manual)
- [ ] Ensure dependencies are pinned to a specific, verified version (Manual)
- [ ] Ensure all packages used are more than 60 days old (Manual)

### Validate Packages

- [ ] Ensure an organization-wide dependency usage policy is enforced (Manual)
- [ ] Ensure packages are automatically scanned for known vulnerabilities (Manual)
- [ ] Ensure packages are automatically scanned for license implications (Manual)
- [ ] Ensure packages are automatically scanned for ownership change (Manual)

## Artifacts

### Verification

- [ ] Ensure all artifacts are signed by the build pipeline itself (Manual)
- [ ] Ensure artifacts are encrypted before distribution (Manual)
- [ ] Ensure only authorized platforms have decryption capabilities of artifacts (Manual)

### Access to Artifacts

- [ ] Ensure the authority to certify artifacts is limited (Manual)
- [ ] Ensure number of permitted users who may upload new artifacts is minimized (Manual)
- [ ] Ensure user access to the package registry utilizes Multi-Factor Authentication (MFA) (Manual)
- [ ] Ensure user management of the package registry is not local (Manual)
- [ ] Ensure anonymous access to artifacts is revoked (Manual)
- [ ] Ensure minimum number of administrators are set for the package registry (Manual)

### Package Registries

- [ ] Ensure all signed artifacts are validated upon uploading the package registry (Manual)
- [ ] Ensure all versions of an existing artifact have their signatures validated (Manual)
- [ ] Ensure changes in package registry configuration are audited (Manual)
- [ ] Ensure webhooks of the repository are secured (Manual)

### Origin Traceability

- [ ] Ensure artifacts contain information about their origin (Manual)

## Deployment

### Deployment Configuration

- [ ] Ensure deployment configuration files are separated from source code (Manual)
- [ ] Ensure changes in deployment configuration are audited (Manual)
- [ ] Ensure scanners are in place to identify and prevent sensitive data in deployment configuration
(Manual)
- [ ] Limit access to deployment configurations (Manual)
- [ ] Scan Infrastructure as Code (IaC) (Manual)
- [ ] Ensure deployment configuration manifests are verified (Manual)
- [ ] Ensure deployment configuration manifests are pinned to a specific, verified version (Manual)

### Deployment Environment

- [ ] Ensure deployments are automated (Manual)
- [ ] Ensure the deployment environment is reproducible (Manual)
- [ ] Ensure access to production environment is limited (Manual)
- [ ] Ensure default passwords are not used (Manual)
