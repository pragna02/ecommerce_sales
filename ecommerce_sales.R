#installing and loading packages
install.packages(c("ggplot2","tidyr","dplyr"))

library(ggplot2)
library(tidyr)
library(dplyr)

#importing and reading dataset
library(readr)
Sales <- read_csv("Downloads/Sales.csv")
head(Sales)
colnames(Sales)

#Calculate Total Orders Day-wise & Revenue generated
install.packages("gridExtra")
library(gridExtra)

day_orders <- Sales %>% 
  select(MONDAY_ORDERS, TUESDAY_ORDERS, WEDNESDAY_ORDERS, THURSDAY_ORDERS, FRIDAY_ORDERS,
         SATURDAY_ORDERS, SUNDAY_ORDERS) %>% 
  gather(key = "Day", value = "Orders")

#plot 
plot_orders <- ggplot(day_orders, aes(x = Day, y = Orders, fill = Day)) +
  geom_bar(stat = "identity") +
  labs(title = "Total Orders by Day of the Week", x = "Day", y = "Total Orders") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

plot_revenue <- ggplot(day_revenue, aes(x = Day, y = Revenue, fill = Day)) +
  geom_bar(stat = "identity") +
  labs(title = "Total Revenue by Day of the Week", x = "Day", y = "Total Revenue") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

grid.arrange(plot_orders, plot_revenue, ncol = 2)

#Average Order Value 
Sales <- Sales %>%
  mutate(LATEST_ORDER_DATE = as.Date(LATEST_ORDER_DATE))

orders_by_month <- Sales %>% 
  mutate(month = format(LATEST_ORDER_DATE, "%Y-%m")) %>% 
  group_by(month) %>% 
  summarize(avg_order_value = mean(AVERAGE_ORDER_VALUE, na.rm = TRUE))

orders_by_month <- orders_by_month %>% 
  mutate(month = as.Date(paste0(month, "-01")))

ggplot(orders_by_month, aes(x = month,  y = avg_order_value)) +
  geom_line() +
  geom_point() +
  labs(title = "Average Order Value Over Time", x = "Month", y = "Average Order Value") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

#Order & Revenue Distribution by Time of Day
time_of_day_orders <- Sales %>%
  select(TIME_0000_0600_ORDERS, TIME_0601_1200_ORDERS, TIME_1200_1800_ORDERS, 
         TIME_1801_2359_ORDERS) %>%
  gather(key = "Time_Period", value = "Orders")

time_of_day_revenue <- Sales %>%
  select(TIME_0000_0600_REVENUE, TIME_0601_1200_REVENUE, TIME_1200_1800_REVENUE, 
         TIME_1801_2359_REVENUE) %>%
  gather(key = "Time_Period", value = "Revenue")

plot_orders_d <- ggplot(time_of_day_orders, aes(x = Time_Period, y = Orders, fill = Time_Period)) +
  geom_bar(stat = "identity") +
  labs(title = "Order Distribution by Time of Day", x = "Time Period", y = "Orders") +
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

plot_revenue_d <- ggplot(time_of_day_revenue, aes(x = Time_Period, y = Revenue, fill = Time_Period)) +
  geom_bar(stat = "identity") +
  labs(title = "Revenue Distribution by Time of Day", x = "Time Period", y = "Revenue") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

grid.arrange(plot_orders_d, plot_revenue_d, ncol = 2)


week_orders <- Sales %>%
  select(WEEK1_DAY01_DAY07_ORDERS, WEEK2_DAY08_DAY15_ORDERS, WEEK3_DAY16_DAY23_ORDERS, 
         WEEK4_DAY24_DAY31_ORDERS) %>%
  gather(key = "Week", value = "Orders") %>%
  group_by(Week) %>%
  summarize(Total_Orders = sum(Orders))

week_revenue <- Sales %>%
  select(WEEK1_DAY01_DAY07_REVENUE,WEEK2_DAY08_DAY15_REVENUE,WEEK3_DAY16_DAY23_REVENUE, 
         WEEK4_DAY24_DAY31_REVENUE) %>%
  gather(key = "Week", value = "Revenue") %>%
  group_by(Week) %>%
  summarize(Total_Revenue = sum(Revenue))

# Function to make donut charts
make_donut_chart <- function(data, value_col, title) {
  data <- data %>%
    mutate(fraction = !!sym(value_col) / sum(!!sym(value_col)),
           ymax = cumsum(fraction),
           ymin = c(0, head(ymax, n = -1)))
  
  ggplot(data, aes(ymax = ymax, ymin = ymin, xmax = 4, xmin = 3, fill = Week)) +
    geom_rect() +
    coord_polar(theta = "y") +
    xlim(c(2, 4)) +
    theme_void() +
    labs(title = title) +
    theme(legend.position = "right")
}

grid.arrange(make_donut_chart(week_orders, "Total_Orders", "Weekly Orders") , make_donut_chart(week_revenue, "Total_Revenue", "Weekly Revenue" ))



