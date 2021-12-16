import numpy as np
import matplotlib.pyplot as plt
import sys

if __name__ == "__main__":
    processes_array = [1, 2, 4, 8, 16, 32]
    #processes_array = [1, 2]
    output = []

    data_filename = sys.argv[1]  # first argument
    data_plot_filename = sys.argv[2]  # second argument

    filename_prefix = data_filename.replace("_data.txt", "")

    with open(data_filename, "r") as file:
        # list_num = list(enumerate(file))
        list_num = [float(line.strip()) for line in file]
        total_num = len(list_num)
        num_per_section = 5

        # for i in range(0, total_num, num_per_section):
        #     section_output = list_num[i:(i + 5)]
        #     output.append(section_output)
        for i in range(num_per_section):
            section_output = list_num[i::num_per_section]
            output.append(section_output)

        file.close()

    for some_output in output:
        print(f"{some_output}")

    # Set position of bar on X axis
    barWidth = 0.25
    br1 = np.arange(len(processes_array))
    br2 = [x + barWidth for x in br1]
    br3 = [x + barWidth for x in br2]
    num_bars = 2

    fig = plt.figure()

    # zorder before plotting...
    plt.gca().set_axisbelow(True)
    plt.grid(True, axis="y", which="both", linestyle='dotted', zorder=0)
    # check if the grid looks good...

    #ax = fig.add_axes([0, 0, 1, 1])
    plt.bar(br1, output[0], color='b', width=barWidth, label=f"Hybrid time",
            log=1, zorder=1)

    # changed from br3 -- stack the repartition time with new hybrid time
    # change so output[3] is on bottom -- new repartitioned hybrid time
    plt.bar(br2, output[3], color='r', width=barWidth, label=f"Repartitioned "
                                                            f"Hybrid time",
            log=1, zorder=1)

    plt.bar(br2, output[2], color='g', width=barWidth, label=f"Repartition "
                                                             f"time",
            bottom=output[3], log=1, zorder=1)

    plt.xlabel(f"Number of processes")
    plt.ylabel(f"Time (s)")
    plt.title(f"{filename_prefix} Plot")

    offset = ((1 / 2) * (num_bars - 1)) * barWidth
    plt.xticks([r + offset for r in range(len(processes_array))],
               processes_array)

    plt.legend()

    plt.savefig(f"{data_plot_filename}")
    #plt.show()

