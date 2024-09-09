# grafite-experiments

This repository provides instructions for automatically running all the experiments from the paper ["Grafite: Taming Adversarial Queries with Optimal Range Filters"](https://doi.org/10.1145/3639258) and recompiling the paper’s PDF with the new figures and tables using Docker. For manual execution, refer to [this guide](https://github.com/marcocosta97/grafite/blob/main/bench/reproducibility.md).

## Requirements

To reproduce the experiments, you need to have Docker installed and configured on your machine (see https://docs.docker.com/engine/install/).

The docker image is based on Ubuntu 20.04 and contains all the necessary software dependencies to run the experiments. It will also download and generate all the needed datasets.

The experiments require a significant amount of memory, *and may fail on machines with less than 64 GB of RAM and 128 GB of disk space.* 

We tested these instruction on the following three machines:
1. **CPU:** Intel Xeon E5-2650Lv3 @ 1.80 GHz. **RAM:** 64 GB. **OS:** Ubuntu 20.04.4 LTS. **Docker version:** 26.1.3
2. **CPU:** Intel Xeon Gold 6140M @ 2.30GHz. **RAM:** 1.17 TB. **OS:** CentOS 7.9.2009. **Docker version:** 26.1.4
3. **CPU:** Intel Xeon Gold 6140M @ 2.30GHz. **RAM:** 1.20 TB. **OS:** CentOS 7.9.2009. **Docker version:** 25.0.3

## Reproducing the experiments

Clone this repository and navigate to its root folder.

Use the following command to build and run the Docker image that executes the experiments. The command also logs the terminal output to the `grafite-log.txt` file.
```bash
(docker build --platform=linux/amd64 -t grafite-experiments . && docker run -ti --name grafite-exp --ulimit core=0 --mount type=bind,source="$(pwd)"/paper_results,target=/app/paper_results grafite-experiments)  2>&1 | tee grafite-log.txt
```

The total execution time of the experiments is approximately **72 hours**, though it may vary depending on the performance of the machine and the speed of the internet connection.

Upon completion, the pdf of the paper, the plots and the raw results in csv format will be available in the `paper_results` folder. The detailed description of the generated figures and tables can be found [here](https://github.com/marcocosta97/grafite/blob/main/bench/reproducibility.md#figures-and-tables).

To remove the Docker container and free up resources, use the following commands:
```bash
docker rm grafite-exp
docker rmi grafite-experiments
```

## Notes on reproducibility

- We do our best to ensure that the experiments are reproducible. However, we cannot fully guarantee on the behavior of competitors range-filters under different platform conditions/memory settings/etc. It may happen that the competitors code crashes due to bugs. In this case, the script will (do its best to) continue to run the other experiments, will plot the results of the successful ones, and will report the failed experiments in the `log.txt` file in the `paper_results` folder.
- The pairwise-independent hash function of Grafite makes use of random coefficients, so the results may slightly vary between different runs. However, they should be consistent with the ones reported in the paper. For more information, see Section 3 of the paper.
- There could be some slightly differences in Proteus plots as their [choice of the sample](https://github.com/Erins-Ransom/Proteus/blob/7580c5b8d184afd19f3fdaf10f782344bdf552f5/include/util.hpp#L57) for the modeling of the data structure is done using a `std::default_random_engine` RNG, which is not guaranteed to be the same across different platforms (see [here](https://en.cppreference.com/w/cpp/numeric/random)). However, the results should be consistent with the ones reported in the paper.

## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details.

If you use the library please cite the following paper:

> Costa, Marco, Paolo Ferragina, and Giorgio Vinciguerra. "Grafite: Taming Adversarial Queries with Optimal Range Filters." Proceedings of the ACM on Management of Data 2.1 (2024): 1-23.

```tex
@article{costa2024grafite,
  title={Grafite: Taming Adversarial Queries with Optimal Range Filters},
  author={Costa, Marco and Ferragina, Paolo and Vinciguerra, Giorgio},
  journal={Proceedings of the ACM on Management of Data},
  volume={2},
  number={1},
  pages={1--23},
  year={2024},
  publisher={ACM New York, NY, USA}
}
```
