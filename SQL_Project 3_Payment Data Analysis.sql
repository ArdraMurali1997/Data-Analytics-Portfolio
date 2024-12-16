#Payment industry KPI Analysis
#------------------------------------------------------------------------------------------
#1. Transactions success % for each merchant
# Transaction success rate= (Number of succesfull transactions/total number of transations)*100

select t.merchant_id, m.name,
concat(round(((sum(case when transaction_status="Success" then 1 else 0 end))/count(*))*100,1),"%") as success_rate
from transactions t join merchants m
on t.merchant_id=m.merchant_id
group by 1,2;
#------------------------------------------------------------------------------------------
#2. Average Dispute Resolution time
#(resolution date-dispute date)/no.of disputes

select avg(datediff(dispute_date,resolution_date)) as avg_res_time from disputes;
#------------------------------------------------------------------------------------------
#3. Successfull Revenue by merchant with revenue rate

select t.merchant_id, m.name,
sum(transaction_amount) as Revenue
from transactions t join merchants m
on t.merchant_id=m.merchant_id
where t.transaction_status="Success"
group by 1,2
order by sum(transaction_amount) desc;
#------------------------------------------------------------------------------------------
#4. Dispute rate per merchant
#(Number of dispute/Number of trasactions)*100

select m.merchant_id,m.name, 
concat(round((count(d.dispute_id)/count(t.transaction_id))*100,1),"%") as dispute_rate
from merchants m join transactions t
on m.merchant_id=t.merchant_id
left join disputes d 
on t.transaction_id=d.transaction_id
group by 1,2
order by 3 desc;
#------------------------------------------------------------------------------------------
#5 Week-wise Revenue

select year(transaction_date),monthname(transaction_date),week(transaction_date),
sum(transaction_amount) from transactions
group by 1,2,3
order by 3;
#------------------------------------------------------------------------------------------
#6 Failed transaction rate by bank

select b.bank_id,b.bank_name,
((sum(case when t.transaction_status="Failed" then 1 else 0 end))/count(t.transaction_id))*100 as failure_rate
from transactions t right join banks b
on t.bank_id=b.bank_id
group by 1,2
order by 3 desc;
#------------------------------------------------------------------------------------------
#7 Top 5 merchants by revenue

select m.merchant_id, m.name, sum(t.transaction_amount) as revenue
from merchants m join transactions t 
on m.merchant_id=t.merchant_id
group by 1,2
order by 3 desc
limit 5;
#------------------------------------------------------------------------------------------
#8  Average transaction amount per user

select u.user_id,u.name,round(avg(t.transaction_amount),2) as average_transaction
from users u join transactions t 
on u.user_id=t.user_id
group by 1,2;
#------------------------------------------------------------------------------------------
#9 Rank dispute reason based on count of dispute

select dispute_reason, count(*) as dispute_count,
sum(dispute_amount) as dispute_amount from disputes
group by 1
order by 2 desc
limit 3;
#------------------------------------------------------------------------------------------
#10 Bank Reconciliation 

select t.transaction_id, t.transaction_amount as phonepe_amt,
bt.amount as bank_amt, t.transaction_status as phonepe_status,bt.status as bank_status
from transactions t left join bank_transactions bt
on t.transaction_id=bt.transaction_id
where t.transaction_amount!=bt.amount or
t.transaction_status != bt.status or
bt.transaction_id is null;



