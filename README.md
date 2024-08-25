# grafite-experiments

This script packages in a Docker container an ***automated way*** to reproduce the results of the paper ["Grafite: Taming Adversarial Queries with Optimal Range Filters"](https://doi.org/10.1145/3639258) as described in [grafite/reproducibility.md](https://github.com/marcocosta97/grafite/blob/main/bench/reproducibility.md). The script will then recompile the LaTeX pdf of the paper using the generated plots and the new query-time tables. Then will copy the pdf of the paper, the plots and the test outputs in csv format on the host machine of the user.

## Requirements

To reproduce the experiments, you need to have Docker installed and configured on your machine (see https://docs.docker.com/engine/install/).

The docker image is based on Ubuntu 20.04 and contains all the necessary dependencies to run the experiments. For an accurate list of the dependencies, see the [Dockerfile](Dockerfile) and [grafite/reproducibility.md](https://github.com/marcocosta97/grafite/blob/main/bench/reproducibility.md).

Note that the dataset generation and the experiments require a significant amount of memory, *and may fail on machines with less than 64GB of RAM and 128GB of available space.* 

## Reproducing the experiments

Clone this repository and navigate to its root folder.

Build the docker image using the following command:
```bash
docker build --platform=linux/amd64 -t grafite-experiments .
```

Run the docker image using the following command, this will start the container and the reproducibility script will run automatically:
```bash
docker run -ti --name grafite-exp --ulimit core=0 --mount type=bind,source="$(pwd)"/paper_results,target=/app/paper_results grafite-experiments
```

Since the first command can take some time to build the image, you may want to concatenate the two operations:
```bash
docker build --platform=linux/amd64 -t grafite-experiments . && docker run -ti --name grafite-exp --ulimit core=0 --mount type=bind,source="$(pwd)"/paper_results,target=/app/paper_results grafite-experiments
```

At the end of the script, the pdf of the paper, the plots and the test outputs in csv format will be available in the `paper_results` folder. The description of the generated figures can be found [here](https://github.com/marcocosta97/grafite/blob/main/bench/reproducibility.md#figures-and-tables).

Close the container and free the resources using the following command:
```bash
docker stop grafite-exp && docker rm grafite-exp
docker rmi grafite-experiments
```

Note that the overall execution time of the experiments is approximately **72 hours**.

## Notes on reproducibility

- We do our best to ensure that the experiments are reproducible. However, we cannot fully guarantee on the behavior of competitors range-filters under different platform conditions/memory settings/etc. It may happen that the competitors range-filters dump core or crash due to memory issues. In this case, the script will (do its best to) continue to run the other experiments, will plot the results of the successful ones, and will report the failed experiments in the `log.txt` file in the `paper_results` folder.
- The pairwise-independent hash function of Grafite makes use of random coefficients, so the results may vary slightly between different runs. However, they should be consistent with the ones reported in the paper. For more information, see [Section 3, Hashing input keys] of the paper.
- There could be some slightly differences in Proteus plots as their [choice of the sample](https://github.com/Erins-Ransom/Proteus/blob/7580c5b8d184afd19f3fdaf10f782344bdf552f5/include/util.hpp#L57) for the modeling of the data structure is done using a `std::default_random_engine` RNG, which is not guaranteed to be the same across different platforms (see [here](https://en.cppreference.com/w/cpp/numeric/random)). However, the results should be consistent with the ones reported in the paper.
- In our experiments, we used NUMA to bind the processes to the cores, which may not be available on all systems. The script will still run without NUMA. If you want to use it, you need to enable it manually from [here](https://github.com/marcocosta97/grafite/blob/7f7552da4ce602b96d24f67466ed828aeda44e4c/bench/scripts/execute_tests.sh#L29).

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
