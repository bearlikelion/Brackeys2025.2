# Brackeys 2025.2 Gamejam GDD

# **Baking Biscuits**

## Theme: Risk it for the Biscuit

**Dates:** 08-24-25 - 08-31-25

## 1. Game Overview

* **Engine:** Godot 4.4.1
* **Pitch:** Player rolls increasing amount of D6 to generate and mutate a biscuit for higher scores
* **Genre:** Dice roller

## 2. Gameplay

* **Core Gameplay Loop:**
  * Players start with a base biscuit (1 dice roll)
  * Each round they roll an increasing number of D6 (1 die / 2 die / 3 die / etc.)
	* Each roll adds a mutation (type, topping, filling, effect)
  * The more dice rolled the more fragile the biscuit becomes
  * Players must choose to **bank** the biscuit or **risk** the biscuit
	* Biscuit calories as score
	  * More filling biscuit = more score
  * Players can choose to **cash out** and submit their score, or **keep rolling** to go for higher scores at the risk of losing it all
* **Controls:** Click buttons to roll dice, see outcomes, and view biscuit mutating
* **User Interface (UI) & Heads-Up Display (HUD):** Sketch out the menus and on-screen information.


## 3. Story

* Bake biscuits to live? Saw themed bakery where you need to appease the master baker to survive? *(too dark?)*

## 4. Art and Audio

* **Art Style:** 3D Realistic Horror Theme
* **Music and Sound Design:** The style of music and the types of sound effects that will be used.

# Dice Types

## Die #1 - Base Type

1. Digestive (Plain, low score, safe)
2. Shortbread (Stable, medium score)
3. Oat (Nutty, adds stability bonus)
4. Chocolate Chip (Higher points, but risky)
5. Biscotti (High score but fragile)
6. Golden Biscuit (Rare, double score)

## Die #2 - Filling

1. Vanilla Cream (safe bonus)
2. Chocolate Cream (big bonus)
3. Jam (gives a second chance if you bust)
4. Peanut Butter (extra points but heavy risk)
5. Marshmallow (x2 toppings)
6. Mystery Filling (roll again)

## Die #3 - Toppings

1. Powdered Sugar (small bonus)
2. Chocolate Drizzle (big score bonus)
3. Sprinkles (bonus to next roll)
4. Caramel (stick biscuit, next roll adds 2 die)
5. Nuts (higher points but increases bust chance)
6. Rainbow Glaze (wild: pick your topping)

## Bonus rolls:

* Rolling doubles = *Cracked Biscuit (lose next round if crack again)*
* Rolling triples = *Exploding Biscuit (insta-bust)*
* Snake eyes = *Stale Biscuit (half score)*

A player can **bank** their biscuit at any time to lock in their score.
If a biscuit breaks, the cookie crumbles and the game ends earning 0 score.

## First Die -> Base biscuit

| Roll | Result | Effect |
| :---: | ----- | ----- |
| 1 | Digestive | +1 point |
| 2 | Shortbread | +2 points |
| 3 | Oat | +2 points (immune to first bust) |
| 4 | Chocolate Chip | +3 points |
| 5 | Biscotti | +5 points (1/6th chance to bust) |
| 6 | Golden Biscuit | +10 points |

## Second Die -> Filling

| Roll | Result | Effect |
| :---: | ----- | ----- |
| 1 | Vanilla Cream | +2 points |
| 2 | Chocolate Cream | +4 points |
| 3 | Jam | +3 points but half score if bust |
| 4 | Peanut Butter | +6 points, bust chance doubles |
| 5 | Marshmallow | +3 points, doubles topping points |
| 6 | Mystery Filling | Roll again  (1-3) = +5 points | (4-6) = bust |

## Third Die -> Topping

| Roll | Result | Effect |
| :---: | ----- | ----- |
| 1 | Powdered Sugar | +1 point |
| 2 | Chocolate Drizzle | +3 points |
| 3 | Sprinkles | +2 points x2 next roll |
| 4 | Caramel Glaze | +4 but next roll is 2 die |
| 5 | Nuts | +5 but +1 to bust next roll |
| 6 | Rainbow Icing *(replace?)* | Wild: choose any topping |

## Fourth Die+ -> Mutations

| Roll | Result | Effect |
| :---: | ----- | ----- |
| 1 | Burnt Edge | -3 Points |
| 2 | Double Stuff | Filling Score x2 |
| 3 | Cracked Biscuit | Another crack = bust |
| 4 | Enchanted Biscuit | Next bust is ignored |
| 5 | Exploding Biscuit | Insta-bust, lose all points |
| 6 | Rainbow Biscuit | +20 points |

##
