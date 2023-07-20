/* 1. How many Olympics Games have been held? */

select count(distinct games) total_olympic_games from athlete_events;


/* 2. List down all Olympics Games held so far with location. */

select distinct games Olymic_games, city location from athlete_events
order by games;


/* 3. Mention the total no of nations who participated in each Olympics game? */

select games, count(distinct noc) No_of_teams
from athlete_events
group by games
order by games;


/* 4. Which year saw the highest and lowest no of countries participating in Olympics? */ 

with max_noc(max_year, max_team) as
		(select games, count(distinct noc) No_of_teams
		from athlete_events
		group by games
		order by games desc
		limit 1),
	min_noc(min_year, min_teams) as
		(select games, count(distinct noc) No_of_teams
		from athlete_events
		group by games
		order by games
		limit 1)
		
select min_year||' - '||min_teams as Min_participation,
max_year||' - '||max_team as Max_participation
from max_noc, min_noc;
	


/* 5. Which nation has participated in all of the Olympic Games? */

select team, count( distinct games) games_count
from athlete_events
group by team
HAVING count( distinct games) = (select count( distinct games) from athlete_events);


/* 6. Identify the sport which was played in all summer Olympics. */

select sport, count( distinct games) games_count
from athlete_events
where season = 'Summer'
group by sport
HAVING count( distinct games) = (select count( distinct games) from athlete_events
								 where season = 'Summer');


/* 7. Which Sports were just played only once in the Olympics? */

select sport, count( distinct games) games_count
from athlete_events
group by sport
having count( distinct games) = 1
order by games_count;

/* 8. Fetch the total no of sports played in each Olympic Games. */

select games, count(distinct sport) Total_sports_played
from athlete_events
group by games;


/* 9. Fetch details of the oldest athletes to win a gold medal. */

select distinct name, age 
from athlete_events
where medal = 'Gold' and 
age in (select max(age) from athlete_events where medal = 'Gold');


/* 10. Find the Ratio of male and female athletes participated in all Olympic Games. */

with cte_m(m_sex, m_count) as 
		(select sex, round(count(*),2) from athlete_events
		group by sex
		having sex = 'M'),
	cte_f(f_sex, f_count) as
		(select sex, round(count(*),2) from athlete_events
		group by sex
		having sex = 'F'),
	cte_total(total_count) as 
		(select round(count(*),2) from athlete_events)

select round((m_count/total_count)*100, 2)||' %' Male_ratio,
round((f_count/total_count)*100, 2)||' %' Female_ratio
from cte_m, cte_f, cte_total;



/* 11. Fetch the top 5 athletes who have won the most gold medals. */

select name, count(medal) Gold_medals
from athlete_events
where medal = 'Gold'
group by name
order by Gold_medals desc
limit 5;


/* 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze). */

select name, count(medal) total_medals
from athlete_events
group by name
order by total_medals desc
limit 5;


/* 13. Fetch the top 5 most successful countries in Olympics. Success is defined by no of medals won. */

select n."Country name" Country, count(medal) total_medals
from athlete_events a
join noc_region n on n.noc = a.noc
group by n."Country name"
order by total_medals desc
limit 5;


/* 14. List down total gold, silver and bronze medals won by each country. */

with gold_cte(gold_noc, gold_count) as
		(select noc, count(*) from athlete_events 
		 where medal = 'Gold'
		 group by noc),
	silver_cte(silver_noc, silver_count) as
		(select noc, count(*) from athlete_events 
		 where medal = 'Silver'
		 group by noc),
	bronze_cte(bronze_noc, bronze_count) as
		(select noc, count(*) from athlete_events 
		 where medal = 'Bronze'
		 group by noc)

select distinct n."Country name", g.gold_count, s.silver_count, b.bronze_count
from athlete_events a
join noc_region n on n.noc = a.noc
join gold_cte g on n.noc = g.gold_noc
join silver_cte s on g.gold_noc = s.silver_noc
join bronze_cte b on s.silver_noc = b.bronze_noc
order by g.gold_count desc, s.silver_count desc, b.bronze_count desc;


/* 15. List down total gold, silver and bronze medals won by each country corresponding to each Olympic Games. */

with gold_cte(game, gold_noc, gold_count) as
		(select games, noc, count(medal) from athlete_events 
		 where medal = 'Gold'
		 group by games, noc
		 order by games, noc),
	silver_cte(game, silver_noc, silver_count) as
		(select games, noc, count(medal) from athlete_events 
		 where medal = 'Silver'
		 group by games, games, noc
		 order by games, noc),
	bronze_cte(game, bronze_noc, bronze_count) as
		(select games, noc, count(medal) from athlete_events 
		 where medal = 'Bronze'
		 group by games, noc
		 order by games, noc)

select distinct a.games, n."Country name", COALESCE(g.gold_count, 0) gold_medals, 
COALESCE(s.silver_count, 0) silver_medals, COALESCE(b.bronze_count, 0) bronze_medals
from noc_region n
join athlete_events a on n.noc = a.noc
left join gold_cte g on a.games = g.game and a.noc = g.gold_noc
left join silver_cte s on a.games = s.game and a.noc = s.silver_noc
left join bronze_cte b on a.games = b.game and a.noc = b.bronze_noc
order by a.games, n."Country name", gold_medals desc, silver_medals desc, bronze_medals desc;

		 
/* 16. Identify which country won the most gold, most silver and most bronze medals 
in each Olympic Games. */

with most_gold_cte as
		(select distinct a.games ggames,
		 first_value(n."Country name") over(partition by a.games order by count(a.medal) desc) gnoc,
		 first_value(count(medal)) over(partition by a.games order by count(a.medal) desc) gmedal
		 from athlete_events a 
		 join noc_region n on n.noc = a.noc
		 where a.medal = 'Gold'
		 group by a.games, n."Country name"
		 order by a.games
		),
	most_silver_cte as
		(select distinct a.games sgames,
		 first_value(n."Country name") over(partition by a.games order by count(a.medal) desc) snoc,
		 first_value(count(medal)) over(partition by a.games order by count(a.medal) desc) smedal
		 from athlete_events a 
		 join noc_region n on n.noc = a.noc
		 where a.medal = 'Silver'
		 group by a.games, n."Country name"
		 order by a.games
		),
	most_bronze_cte as
		(select distinct a.games bgames,
		 first_value(n."Country name") over(partition by a.games order by count(a.medal) desc) bnoc,
		 first_value(count(medal)) over(partition by a.games order by count(a.medal) desc) bmedal
		 from athlete_events a 
		 join noc_region n on n.noc = a.noc
		 where a.medal = 'Bronze'
		 group by a.games, n."Country name"
		 order by a.games
		)

select distinct a.games, gnoc||' - '||gmedal most_gold_medals,
snoc||' - '||smedal most_silver_medals,
bnoc||' - '||bmedal most_bronze_medals
from athlete_events a
join most_gold_cte mgc on a.games = mgc.ggames
join most_silver_cte msc on mgc.ggames = msc.sgames
join most_bronze_cte mbc on msc.sgames = mbc.bgames
order by a.games;



/* 17. Identify which country won the most gold, most silver, most bronze medals and 
the most medals in each Olympic Games. */

with most_gold_cte as
		(select distinct a.games ggames,
		 first_value(n."Country name") over(partition by a.games order by count(a.medal) desc) gnoc,
		 first_value(count(medal)) over(partition by a.games order by count(a.medal) desc) gmedal
		 from athlete_events a 
		 join noc_region n on n.noc = a.noc
		 where a.medal = 'Gold'
		 group by a.games, n."Country name"
		 order by a.games
		),
	most_silver_cte as
		(select distinct a.games sgames,
		 first_value(n."Country name") over(partition by a.games order by count(a.medal) desc) snoc,
		 first_value(count(medal)) over(partition by a.games order by count(a.medal) desc) smedal
		 from athlete_events a 
		 join noc_region n on n.noc = a.noc
		 where a.medal = 'Silver'
		 group by a.games, n."Country name"
		 order by a.games
		),
	most_bronze_cte as
		(select distinct a.games bgames,
		 first_value(n."Country name") over(partition by a.games order by count(a.medal) desc) bnoc,
		 first_value(count(medal)) over(partition by a.games order by count(a.medal) desc) bmedal
		 from athlete_events a 
		 join noc_region n on n.noc = a.noc
		 where a.medal = 'Bronze'
		 group by a.games, n."Country name"
		 order by a.games
		),
	most_medals_cte as
		(select distinct a.games mgames,
		 first_value(n."Country name") over(partition by a.games order by count(a.medal) desc) mnoc,
		 first_value(count(medal)) over(partition by a.games order by count(a.medal) desc) mmedal
		 from athlete_events a 
		 join noc_region n on n.noc = a.noc
		 group by a.games, n."Country name"
		 order by a.games
		)

select distinct a.games, gnoc||' - '||gmedal most_gold_medals,
snoc||' - '||smedal most_silver_medals,
bnoc||' - '||bmedal most_bronze_medals,
mnoc||' - '||mmedal most_medals
from athlete_events a
join most_gold_cte mgc on a.games = mgc.ggames
join most_silver_cte msc on mgc.ggames = msc.sgames
join most_bronze_cte mbc on msc.sgames = mbc.bgames
join most_medals_cte mmc on mbc.bgames = mmc.mgames
order by a.games;


/* 18. Which countries have never won gold medal but have won silver/bronze medals? */

with noc_cte(noc1) as
	(select distinct noc from athlete_events 
	 where noc not in (select noc from athlete_events where medal = 'Gold'))
	 
select distinct n."Country name" country from noc_cte nc
join noc_region n on n.noc = nc.noc1
where noc1 in (select noc from athlete_events where medal = 'Silver')
or noc1 in (select noc from athlete_events where medal = 'Bronze');


/* 19. In which Sport/event, India has won highest medals. */

select n."Country name" country, sport, count(medal) total_medals
from athlete_events a 
join noc_region n on n.noc = a.noc
where n."Country name" = 'India'
group by n."Country name", sport
order by total_medals desc
limit 1;


/* 20. Break down all Olympic Games where India won medal for Hockey and how many medals in each Olympic Games. */

select n."Country name" country, games, sport, count(medal) medals_count
from athlete_events a 
join noc_region n on n.noc = a.noc
where n."Country name" = 'India' and sport = 'Hockey'
group by n."Country name", games, sport
order by games, sport, medals_count desc;