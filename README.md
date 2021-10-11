# Web UI Github Actions runner

Based on the work done in https://github.com/bharathkkb/gh-runners/tree/master/gke

Regularly builds and deploys a new runner image to be used by [Nuxeo Web UI](https://github.com/nuxeo/nuxeo-web-ui).

### Prerequisites

- `kubectl`
- k8s cluster (if the `webui` namespace doesn't exist, one is created by the `build` workflow)

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html) 

(C) Copyright Nuxeo Corp. (http://nuxeo.com/)

All images, icons, fonts, and videos contained in this folder are copyrighted by Nuxeo, all rights reserved.

## About Nuxeo

Nuxeo dramatically improves how content-based applications are built, managed and deployed, making customers more agile, innovative and successful. Nuxeo provides a next generation, enterprise ready platform for building traditional and cutting-edge content oriented applications. Combining a powerful application development environment with SaaS-based tools and a modular architecture, the Nuxeo Platform and Products provide clear business value to some of the most recognizable brands including Verizon, Electronic Arts, Sharp, FICO, the U.S. Navy, and Boeing. Nuxeo is headquartered in New York and Paris. More information is available at www.nuxeo.com.



