# Contributing to Salesforce CLI

Thank you for your interest in contributing to Salesforce CLI! We welcome contributions from the community and are excited to work with you.

## Getting Started

1. Fork the repository on GitHub.
2. Clone your forked repository to your local machine.
3. Create a new branch for your contribution.
4. Make your changes and commit them with a clear and concise commit message.
5. Push your changes to your forked repository.
6. Open a pull request against the main repository.

## Testing Docker Build Workflows

We have introduced a new capability for contributors to test the Docker build workflows in their forks. You can now create a branch starting with `docker/` to trigger the test Docker build workflow. This workflow will run on all pushes in forks and publish to the local package registry in the repository.

### Steps to Test Docker Build Workflows

1. Create a new branch in your forked repository with a name starting with `docker/`.
2. Make your changes to the Dockerfile or related workflows.
3. Push your changes to the `docker/` branch.
4. The test Docker build workflow will automatically run and publish the Docker images to the local package registry in the repository.

## Code of Conduct

Please note that this project is governed by the Salesforce Code of Conduct. By participating, you are expected to adhere to this code. Please report any unacceptable behavior to [oss@salesforce.com](mailto:oss@salesforce.com).

## License

By contributing to Salesforce CLI, you agree that your contributions will be licensed under the [BSD 3-Clause License](LICENSE.txt).

Thank you for contributing to Salesforce CLI!
