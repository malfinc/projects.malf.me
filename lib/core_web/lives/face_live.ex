defmodule CoreWeb.FaceLive do
  use Phoenix.LiveView,
    layout: {CoreWeb.LayoutView, :face}
  use Phoenix.HTML

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> (&{:ok, &1}).()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> assign(:awake, false)
    |> assign(:talking, false)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("wake-up", _params, socket) do
    socket
    |> assign(:awake, true)
    |> (&{:noreply, &1}).()
  end

  def handle_event("move-eye", %{"to" => direction}, socket) do
    socket
    |> assign(:eye_sweep, direction)
    |> (&{:noreply, &1}).()
  end

  def handle_event("talking", _params, socket) do
    socket
    |> assign(:talking, true)
    |> (&{:noreply, &1}).()
  end

  def handle_event("quiet", _params, socket) do
    socket
    |> assign(:talking, false)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <svg
      id="FaceLive"
      phx-hook="Face"
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      x="0px"
      y="0px"
      viewBox="0 0 2466.9 3192.4"
      style="enable-background: new 0 0 2466.9 3192.4"
      xml:space="preserve"
    >
      <style type="text/css">
        .hair {
          fill: #8ec540;
          stroke: #000000;
          stroke-width: 76;
          stroke-linejoin: round;
          stroke-miterlimit: 10;
        }
        .eye {
          fill: #ffffff;
          stroke: #000000;
          stroke-width: 95;
          stroke-miterlimit: 10;
        }
        .skin {
          fill: #ed1d23;
          stroke: #000000;
          stroke-width: 95;
          stroke-linecap: round;
          stroke-linejoin: round;
          stroke-miterlimit: 10;
        }
        .skin-2 {
          fill: #ed1d23;
        }
        .unknown {
          fill: none;
          stroke: #000000;
          stroke-width: 107;
          stroke-linecap: round;
          stroke-linejoin: round;
          stroke-miterlimit: 10;
        }
        .ear {
          fill: none;
          stroke: #000000;
          stroke-width: 95;
          stroke-linecap: round;
          stroke-linejoin: round;
          stroke-miterlimit: 10;
        }
      </style>
      <g id="Layer_2"></g>
      <g id="Layer_1">
        <path
          class="hair"
          d="M1278.2,175.8c68.3,4.7,119,60.7,113.2,125c-5.8,64.3-66,112.7-134.3,107.9c0,0-96.1-25.7-156.6,6.1
            c-76.3,40.1-85.5,92.7-85.5,92.7l-0.3,160.4l-175.1,1.6C804,505.3,586.7,548.3,586.7,548.3c-68.3,6.5-128.6-40.3-134.7-104.5
            s44.4-121.4,112.7-127.9c0,0,234.8-43.7,283.3,97c0,0-24.7-109,126.1-186.4c21.2-10.9,61.9-39,127.8-49.1
            C1186.1,164.5,1278.2,175.8,1278.2,175.8z"
        />
        <%= eye(assigns) %>
        <%= mouth(assigns) %>
        <path
          class="ear"
          d="M846.8,1736.6c-111.7,0-202.2-90.6-202.2-202.2s90.6-202.2,202.2-202.2"
        />
        <path
          class="ear"
          d="M864.8,1534.4c111.7,0,202.2,90.6,202.2,202.2c0,111.7-90.6,202.2-202.2,202.2"
        />
      </g>
    </svg>
    """
  end

  defp mouth(%{talking: false} = assigns) do
    ~H"""
    <g>
      <g>
        <path
          class="skin"
          d="M1233.7,624.2c163.1,3.7,398.6,115.2,498.2,409.8c9.3,27.5,15.4,108.6-41.2,108.6l-144.7-2.3
            c-104.9,0-190,85.1-190,190c0,104.9,85.1,190,190,190h185.9c71.7,0,129.8,58.1,129.8,129.8c0,71.7-58.1,129.8-129.8,129.8h-175.7
            c-45.1,0-81.7,36.6-81.7,81.7c0,45.1,36.6,81.7,81.7,81.7l358.1-5.5l9.2,0c44.6,0,80.7,36.1,80.7,80.7
            c0,44.6-36.1,80.7-80.7,80.7h-291.2l291.2,0c44.6,0,80.7,36.1,80.7,80.7s-36.1,80.7-80.7,80.7h-291.2c0,0,300.3-1.8,321.2,0.9
            c70.9,9.1,177.7,80.1,177.7,234.9c0,168.3-135,260.1-210.1,260.1c-75.2,0-323.6-2.7-510.8-69.3
            c-187.2-66.6-685.8-241.2-970.2-838.8c0,0-97.1-275.5-102.6-423c-5.4-145.8-7.9-236.6,0-315c18-178.2,205.2-455.4,451.8-486
            C899.6,610.5,1122.6,621.7,1233.7,624.2z"
        />
        <g>
          <path class="skin-2" d="M1632.3,2255.6" />
          <path class="unknown" d="M1632.3,2255.6" />
        </g>
      </g>
    </g>
    """
  end

  defp mouth(%{talking: true} = assigns) do
    ~H"""
    <g>
      <g>
        <path class="skin" d="M 1233.7 624.2 C 1396.8 627.9 1632.3 739.4 1731.9 1034 C 1741.2 1061.5 1747.3 1142.6 1690.7 1142.6 L 1546 1140.3 C 1441.1 1140.3 1356 1225.4 1356 1330.3 C 1356 1435.2 1441.1 1520.3 1546 1520.3 L 1731.9 1520.3 C 1803.6 1520.3 1861.7 1578.4 1861.7 1650.1 C 1861.7 1721.8 1803.6 1779.9 1731.9 1779.9 L 1556.2 1779.9 C 1511.1 1779.9 1474.5 1816.5 1474.5 1861.6 C 1474.5 1906.7 1511.1 1943.3 1556.2 1943.3 L 1914.3 1937.8 L 1923.5 1937.8 C 1968.1 1937.8 2004.2 1973.9 2004.2 2018.5 C 2004.2 2031.609 1999.112 2021.636 1971.535 2079.96 C 1951.367 2122.614 1720.682 2098.839 1711.43 2098.839 L 1624.124 2087.831 L 1589.879 2094.21 L 1550.837 2102.834 L 1528.735 2115.398 L 1499.237 2140.917 L 1493.304 2169.683 L 1495.806 2194.805 L 1519.278 2228.511 L 1544.758 2239.05 L 1600.705 2253.935 L 1924.804 2256.755 C 1969.404 2256.755 1980.125 2275.935 1980.125 2320.535 C 1980.125 2365.135 1944.025 2401.235 1899.425 2401.235 L 1608.225 2401.235 C 1608.225 2401.235 1908.525 2399.435 1929.425 2402.135 C 2000.325 2411.235 2107.125 2482.235 2107.125 2637.035 C 2107.125 2805.335 1972.125 2897.135 1897.025 2897.135 C 1821.825 2897.135 1573.425 2894.435 1386.225 2827.835 C 1199.025 2761.235 724.5 2446 440.1 1848.4 C 440.1 1848.4 343 1572.9 337.5 1425.4 C 332.1 1279.6 329.6 1188.8 337.5 1110.4 C 355.5 932.2 542.7 655 789.3 624.4 C 899.6 610.5 1122.6 621.7 1233.7 624.2 Z" style="fill: rgb(237, 29, 35); stroke-linecap: round; stroke-linejoin: round; stroke-miterlimit: 10; stroke-width: 95px; stroke: rgb(0, 0, 0);"/>
        <g>
          <path class="skin-2" d="M1632.3,2255.6" style="fill: rgb(237, 29, 35);"/>
          <path class="unknown" d="M1632.3,2255.6" style="fill: none; stroke: rgb(0, 0, 0); stroke-linecap: round; stroke-linejoin: round; stroke-miterlimit: 10; stroke-width: 107px;"/>
        </g>
        <path style="stroke: rgb(237, 29, 35); fill: rgb(237, 29, 35);" d="M 2538.505 3119.296 C 2538.505 3115.887 2540.195 3112.63 2542.197 3111.295 C 2542.574 3111.044 2542.162 3109.069 2542.607 3109.244 C 2555.435 3114.283 2544.427 3107.45 2545.274 3106.577 C 2545.53 3106.313 2533.641 3120.023 2534.08 3119.583 C 2535.702 3117.961 2551.86 3114.45 2554.795 3112.688 C 2556.547 3111.637 2581.621 3105.109 2583.25 3103.48 C 2583.447 3103.284 2559.37 3091.854 2559.634 3092.012 C 2576.472 3102.121 2561.502 3090.749 2561.891 3090.166 C 2562.08 3089.881 2562.632 3090.355 2562.917 3090.166 C 2563.743 3089.615 2564.896 3089.417 2565.583 3088.73 C 2565.956 3088.357 2568.332 3088.606 2568.66 3088.114 C 2569.098 3087.457 2570.662 3086.917 2571.327 3086.473 C 2571.572 3086.31 2572.813 3086.707 2572.969 3086.473 C 2573.959 3084.989 2577.431 3085.087 2578.712 3083.806 C 2579.722 3082.797 2585.036 3084.266 2583.636 3082.165 C 2583.063 3081.306 2579.712 3080.824 2578.712 3080.524 C 2576.987 3080.006 2575.675 3079.416 2574.199 3078.678 C 2573.504 3078.33 2581.088 3101.306 2580.425 3100.909 C 2578.849 3099.964 2568.151 3078.029 2566.404 3077.447 C 2564.949 3076.962 2563.374 3077.277 2561.891 3076.832 C 2556.222 3075.131 2552.449 3073.344 2546.095 3073.344 C 2544.578 3073.344 2541.087 3072.738 2539.736 3073.549 C 2535.414 3076.143 2529.84 3079.047 2526.196 3083.601 C 2525.513 3084.455 2523.966 3084.395 2523.324 3085.037 C 2514.161 3094.198 2526.491 3082.344 2522.709 3086.884 C 2519.842 3090.325 2515.872 3093.86 2517.785 3099.602 C 2518.875 3102.872 2521.675 3104.69 2523.94 3106.577 C 2525.083 3107.53 2523.934 3107.678 2525.375 3108.218 C 2526.805 3108.754 2528.473 3109.059 2529.273 3109.859 C 2529.957 3110.543 2532.077 3109.791 2532.761 3110.475 C 2533.547 3111.261 2534.231 3112.15 2535.017 3112.937 C 2535.387 3113.306 2534.723 3114.752 2535.017 3115.193 C 2535.782 3116.34 2535.412 3117.94 2536.043 3118.885 C 2536.071 3118.928 2538.042 3118.955 2538.094 3118.885 C 2538.259 3118.667 2600.069 3098.994 2600.342 3098.994"/>
        <rect x="2532.201" y="3041.633" width="132.099" height="62.117" style="paint-order: fill; stroke: rgb(237, 29, 35); fill: rgb(237, 29, 35);"/>
        <path style="stroke: rgb(237, 29, 35); fill: rgb(237, 29, 35);" d="M 2530.118 3029.228 C 2531.657 3029.228 2533.774 3030.235 2535.452 3031.074 C 2536.615 3031.655 2537.695 3031.064 2538.529 3031.689 C 2539.715 3032.579 2550.987 3035.288 2552.403 3035.76 C 2557.549 3037.476 2566.936 3037.812 2572 3039.194 C 2574.128 3039.774 2576.788 3039.005 2578.219 3039.863 C 2578.844 3040.238 2583.69 3040.189 2584.395 3040.424 C 2587.374 3041.417 2598.324 3039.577 2600.332 3041.084 C 2601.076 3041.642 2598.162 3040.806 2598.906 3041.364 C 2600.503 3042.561 2599.127 3040.767 2600.245 3042.444 C 2600.37 3042.631 2603.559 3042.162 2603.83 3042.433 C 2604.641 3043.244 2602.118 3041.673 2602.847 3042.767 C 2603.136 3043.202 2601.3 3040.719 2601.097 3041.126 C 2600.949 3041.421 2597.571 3041.126 2596.994 3041.126 C 2592.945 3041.126 2588.759 3041.136 2585.096 3042.357 C 2581.317 3043.617 2577.8 3045.463 2573.813 3046.46 C 2571.298 3047.088 2567.551 3046.066 2565.197 3047.075 C 2562.326 3048.306 2556.305 3048.283 2553.299 3047.28 C 2550.279 3046.273 2546.301 3048.251 2543.657 3046.665 C 2542.51 3045.976 2538.682 3046.665 2537.298 3046.665 C 2536.326 3046.665 2536.629 3046.049 2535.657 3046.049 C 2534.963 3046.049 2533.116 3046.407 2532.58 3046.049 C 2532.34 3045.89 2532.369 3045.223 2532.169 3045.024 C 2531.894 3044.748 2530.473 3044.645 2530.118 3044.408 C 2529.154 3043.766 2527.156 3041.524 2526.426 3040.305 C 2525.036 3037.989 2525.54 3035.177 2522.117 3035.177"/>
      </g>
    </g>
    """
  end

  defp eye(%{awake: false} = assigns) do
    ~H"""
    <g>
      <circle class="eye" cx="1546" cy="1330.3" r="190" />
      <circle class="iris" cx="1546" cy="1330.3" r="0" />
    </g>
    """
  end

  defp eye(%{awake: true, eye_sweep: "left"} = assigns) do
    ~H"""
    <g>
      <circle class="eye" cx="1546" cy="1330.3" r="190" />
      <circle class="iris" cx="1546" cy="1330.3" r="70">
        <animate
          attributeName="cx"
          by="-100"
          dur="10s"
          repeatCount="indefinite" />
      </circle>
    </g>
    """
  end

  defp eye(%{awake: true, eye_sweep: "right"} = assigns) do
    ~H"""
    <g>
      <circle class="eye" cx="1546" cy="1330.3" r="190" />
      <circle class="iris" cx="1546" cy="1330.3" r="70">
        <animate
          attributeName="cx"
          by="100"
          dur="10s"
          repeatCount="indefinite" />
      </circle>
    </g>
    """
  end

  defp eye(%{awake: true} = assigns) do
    ~H"""
    <g>
      <circle class="eye" cx="1546" cy="1330.3" r="190" />
      <circle class="iris" cx="1546" cy="1330.3" r="70" />
    </g>
    """
  end
end
