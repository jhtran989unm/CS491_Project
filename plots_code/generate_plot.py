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

    #######################################

    # plt.figure(1)
    fig, ax = plt.subplots()

    # Second, remove the ticks as well.
    # ax.tick_params(bottom=False, left=False)
    plt.tick_params(bottom=False, left=False)

    # First, let's remove the top, right and left spines (figure borders)
    # which really aren't necessary for a bar chart.
    # Also, make the bottom spine gray instead of black.
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['bottom'].set_color('#DDDDDD')

    # Second, remove the ticks as well.
    ax.tick_params(bottom=False, left=False)
    plt.tick_params(bottom=False, left=False)

    # Third, add a horizontal grid (but keep the vertical grid hidden).
    # Color the lines a light gray as well.
    ax.set_axisbelow(True)
    # ax.yaxis.grid(True, color='#EEEEEE')
    # ax.xaxis.grid(False)

    #fig.tight_layout()

    # zorder before plotting...
    #ax.set_axisbelow(True)
    #plt.grid(True, axis="y", which="both", linestyle='dotted', zorder=0)
    plt.grid(True, axis="y", color='#EEEEEE', which="both",
             linestyle='dotted', zorder=0)
    # check if the grid looks good...

    #ax = fig.add_axes([0, 0, 1, 1])

    # color='...'
    # blue - b
    plt.bar(br1, output[0], color='b', width=barWidth, label=f"Hybrid time",
            log=1, zorder=1)

    # changed from br3 -- stack the repartition time with new hybrid time
    # change so output[3] is on bottom -- new repartitioned hybrid time
    # red - r
    plt.bar(br2, output[3], color='r', width=barWidth, label=f"Repartitioned "
                                                            f"Hybrid time",
            log=1, zorder=1)

    # green - g
    plt.bar(br2, output[2], color='g', width=barWidth, label=f"Repartition "
                                                             f"time",
            bottom=output[3], log=1, zorder=1)

    plt.xlabel(f"Number of processes")
    plt.ylabel(f"Time (s)")
    plt.title(f"{filename_prefix} Timings Plot")

    offset = ((1 / 2) * (num_bars - 1)) * barWidth
    plt.xticks([r + offset for r in range(len(processes_array))],
               processes_array)

    plt.legend()

    # Second, remove the ticks as well.
    # ax.tick_params(bottom=False, left=False)
    plt.tick_params(bottom=False, left=False)

    plt.savefig(f"{filename_prefix}_timings_plot.png")

    #plt.close(fig)

    #######################################

    # plt.figure(1)
    fig, ax = plt.subplots()

    # Second, remove the ticks as well.
    # ax.tick_params(bottom=False, left=False)
    plt.tick_params(bottom=False, left=False)

    # First, let's remove the top, right and left spines (figure borders)
    # which really aren't necessary for a bar chart.
    # Also, make the bottom spine gray instead of black.
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['bottom'].set_color('#DDDDDD')

    # Second, remove the ticks as well.
    ax.tick_params(bottom=False, left=False)
    plt.tick_params(bottom=False, left=False)

    # Third, add a horizontal grid (but keep the vertical grid hidden).
    # Color the lines a light gray as well.
    ax.set_axisbelow(True)
    # ax.yaxis.grid(True, color='#EEEEEE')
    # ax.xaxis.grid(False)

    #fig.tight_layout()

    # zorder before plotting...
    #ax.set_axisbelow(True)
    # plt.grid(True, axis="y", which="both", linestyle='dotted', zorder=0)
    plt.grid(True, axis="y", color='#EEEEEE', which="both",
             linestyle='dotted', zorder=0)
    # check if the grid looks good...

    # ax = fig.add_axes([0, 0, 1, 1])
    plt.bar(br1, output[1], color='b', width=barWidth, label=f"Hybrid Residual",
            log=1, zorder=1)

    # changed from br3 -- stack the repartition time with new hybrid time
    # change so output[3] is on bottom -- new repartitioned hybrid time
    plt.bar(br2, output[4], color='r', width=barWidth, label=f"Repartitioned "
                                                             f"Hybrid Residual",
            log=1, zorder=1)

    plt.xlabel(f"Number of processes")
    plt.ylabel(f"Residual")
    plt.title(f"{filename_prefix} Residual Plot")

    offset = ((1 / 2) * (num_bars - 1)) * barWidth
    plt.xticks([r + offset for r in range(len(processes_array))],
               processes_array)

    plt.legend()

    # Second, remove the ticks as well.
    # ax.tick_params(bottom=False, left=False)
    plt.tick_params(bottom=False, left=False)

    plt.savefig(f"{filename_prefix}_residual_plot.png")

    #plt.close(fig)

    #plt.show()

