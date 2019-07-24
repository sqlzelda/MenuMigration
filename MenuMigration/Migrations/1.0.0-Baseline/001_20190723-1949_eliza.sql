-- <Migration ID="7262bf5b-5b05-4255-948d-502f2fdab695" />
GO

PRINT N'Creating [dbo].[Ingredient]'
GO
CREATE TABLE [dbo].[Ingredient]
(
[IngredientID] [int] NOT NULL IDENTITY(1, 1),
[IngredientName] [varchar] (25) NOT NULL,
[IsActive] [bit] NOT NULL,
[DateCreated] [datetime2] NOT NULL,
[DateModified] [datetime2] NOT NULL
)
GO
PRINT N'Creating primary key [PK_Ingredient_IngredientID] on [dbo].[Ingredient]'
GO
ALTER TABLE [dbo].[Ingredient] ADD CONSTRAINT [PK_Ingredient_IngredientID] PRIMARY KEY CLUSTERED  ([IngredientID])
GO
PRINT N'Creating [dbo].[IngredientCost]'
GO
CREATE TABLE [dbo].[IngredientCost]
(
[IngredientCostID] [int] NOT NULL IDENTITY(1, 1),
[IngredientID] [int] NOT NULL,
[ServingPortionID] [tinyint] NOT NULL,
[Cost] [decimal] (6, 3) NOT NULL,
[IsActive] [bit] NOT NULL,
[DateCreated] [datetime2] NOT NULL,
[DateModified] [datetime2] NOT NULL
)
GO
PRINT N'Creating primary key [PK_IngredientCost_IngredientCostID] on [dbo].[IngredientCost]'
GO
ALTER TABLE [dbo].[IngredientCost] ADD CONSTRAINT [PK_IngredientCost_IngredientCostID] PRIMARY KEY CLUSTERED  ([IngredientCostID])
GO
PRINT N'Creating [dbo].[ServingPortion]'
GO
CREATE TABLE [dbo].[ServingPortion]
(
[ServingPortionID] [tinyint] NOT NULL IDENTITY(1, 1),
[ServingPortionQuantity] [tinyint] NOT NULL,
[ServingPortionUnit] [varchar] (4) NOT NULL,
[IsActive] [bit] NOT NULL,
[DateCreated] [datetime2] NOT NULL,
[DateModified] [datetime2] NOT NULL
)
GO
PRINT N'Creating primary key [PK_ServingPortion_ServingPortionID] on [dbo].[ServingPortion]'
GO
ALTER TABLE [dbo].[ServingPortion] ADD CONSTRAINT [PK_ServingPortion_ServingPortionID] PRIMARY KEY CLUSTERED  ([ServingPortionID])
GO
PRINT N'Creating [dbo].[IngredientNutrition]'
GO
CREATE TABLE [dbo].[IngredientNutrition]
(
[IngredientNutritionID] [int] NOT NULL IDENTITY(1, 1),
[ServingPortionID] [tinyint] NOT NULL,
[Calories] [tinyint] NOT NULL,
[Carbohydrates] [tinyint] NOT NULL,
[Sugar] [tinyint] NOT NULL,
[Fiber] [tinyint] NOT NULL,
[Protein] [tinyint] NOT NULL,
[IsActive] [bit] NOT NULL,
[DataCreated] [datetime2] NOT NULL,
[DateModified] [datetime2] NOT NULL
)
GO
PRINT N'Creating primary key [PK_IngredientNutrition_IngredientNutritionID] on [dbo].[IngredientNutrition]'
GO
ALTER TABLE [dbo].[IngredientNutrition] ADD CONSTRAINT [PK_IngredientNutrition_IngredientNutritionID] PRIMARY KEY CLUSTERED  ([IngredientNutritionID])
GO
PRINT N'Creating [dbo].[RecipeIngredient]'
GO
CREATE TABLE [dbo].[RecipeIngredient]
(
[RecipeIngredientID] [int] NOT NULL IDENTITY(1, 1),
[RecipeID] [smallint] NOT NULL,
[IngredientID] [int] NOT NULL,
[ServingPortionID] [tinyint] NOT NULL,
[IsActive] [bit] NOT NULL,
[DateCreated] [datetime2] NOT NULL,
[DateModified] [datetime2] NOT NULL
)
GO
PRINT N'Creating primary key [PK_RecipeIngredient_RecipeIngredientID] on [dbo].[RecipeIngredient]'
GO
ALTER TABLE [dbo].[RecipeIngredient] ADD CONSTRAINT [PK_RecipeIngredient_RecipeIngredientID] PRIMARY KEY CLUSTERED  ([RecipeIngredientID])
GO
PRINT N'Creating [dbo].[Recipe]'
GO
CREATE TABLE [dbo].[Recipe]
(
[RecipeID] [smallint] NOT NULL IDENTITY(1, 1),
[RecipeName] [varchar] (25) NOT NULL,
[RecipeDescription] [varchar] (50) NOT NULL,
[ServingQuantity] [tinyint] NOT NULL,
[MealTypeID] [tinyint] NOT NULL,
[PreparationTypeID] [tinyint] NOT NULL,
[IsActive] [bit] NOT NULL,
[DateCreated] [datetime2] NOT NULL,
[DateModified] [datetime2] NOT NULL
)
GO
PRINT N'Creating primary key [PK_Recipe_RecipeID] on [dbo].[Recipe]'
GO
ALTER TABLE [dbo].[Recipe] ADD CONSTRAINT [PK_Recipe_RecipeID] PRIMARY KEY CLUSTERED  ([RecipeID])
GO
PRINT N'Creating [dbo].[MealType]'
GO
CREATE TABLE [dbo].[MealType]
(
[MealTypeID] [tinyint] NOT NULL IDENTITY(1, 1),
[MealTypeName] [varchar] (25) NOT NULL,
[MealTypeDescription] [varchar] (50) NOT NULL,
[IsActive] [bit] NOT NULL,
[DateCreated] [datetime2] NOT NULL,
[DateModified] [datetime2] NOT NULL
)
GO
PRINT N'Creating primary key [PK_MealType_MealTypeID] on [dbo].[MealType]'
GO
ALTER TABLE [dbo].[MealType] ADD CONSTRAINT [PK_MealType_MealTypeID] PRIMARY KEY CLUSTERED  ([MealTypeID])
GO
PRINT N'Creating [dbo].[AvailableMeal]'
GO
CREATE VIEW [dbo].[AvailableMeal]
WITH SCHEMABINDING
AS
SELECT meal.MealTypeName, rec.RecipeName, rec.ServingQuantity, ing.IngredientName
FROM dbo.Recipe rec
	INNER JOIN dbo.MealType meal
	ON rec.MealTypeID = meal.MealTypeID
	INNER JOIN dbo.RecipeIngredient recing
	ON rec.RecipeID = recing.RecipeID
	INNER JOIN dbo.Ingredient ing
	ON recing.IngredientID = ing.IngredientID
GO
PRINT N'Creating index [CX_AvailableMeal_RecipeNameIngredientName] on [dbo].[AvailableMeal]'
GO
CREATE UNIQUE CLUSTERED INDEX [CX_AvailableMeal_RecipeNameIngredientName] ON [dbo].[AvailableMeal] ([RecipeName], [IngredientName])
GO
PRINT N'Creating [dbo].[IngredientListByCost]'
GO
CREATE FUNCTION [dbo].[IngredientListByCost] (@Cost DECIMAL(6,3))
RETURNS @Output TABLE
(
	IngredientID			INT,
    IngredientName			VARCHAR(25),
	IngredientCost			DECIMAL(6,3)
)
AS
    BEGIN
        INSERT INTO @Output (IngredientID, IngredientName, IngredientCost)
        SELECT   ing.IngredientID, ing.IngredientName, ingcos.Cost
        FROM     dbo.Ingredient ing
			INNER JOIN dbo.IngredientCost ingcos
			ON ing.IngredientID = ingcos.IngredientID
        WHERE	 ingcos.Cost > @Cost;
        RETURN;
    END;
GO
PRINT N'Creating [dbo].[Ingredient_Price]'
GO
CREATE FUNCTION [dbo].[Ingredient_Price](@Cost DECIMAL(6,3), @Count DECIMAL(6,3))
RETURNS DECIMAL (6,3) AS
BEGIN
       RETURN @Cost / @Count;
END
GO
PRINT N'Creating [dbo].[PreparationType]'
GO
CREATE TABLE [dbo].[PreparationType]
(
[PreparationTypeID] [tinyint] NOT NULL IDENTITY(1, 1),
[PreparationTypeName] [varchar] (25) NOT NULL,
[PreparationTypeDescription] [varchar] (50) NOT NULL,
[IsActive] [bit] NOT NULL,
[DateCreated] [datetime2] NOT NULL,
[DateModified] [datetime2] NOT NULL
)
GO
PRINT N'Creating primary key [PK_PreparationType_PreparationTypeID] on [dbo].[PreparationType]'
GO
ALTER TABLE [dbo].[PreparationType] ADD CONSTRAINT [PK_PreparationType_PreparationTypeID] PRIMARY KEY CLUSTERED  ([PreparationTypeID])
GO
PRINT N'Adding foreign keys to [dbo].[IngredientCost]'
GO
ALTER TABLE [dbo].[IngredientCost] ADD CONSTRAINT [FK_IngredientCost_IngredientID] FOREIGN KEY ([IngredientID]) REFERENCES [dbo].[Ingredient] ([IngredientID])
GO
ALTER TABLE [dbo].[IngredientCost] ADD CONSTRAINT [FK_IngredientCost_ServingPortionID] FOREIGN KEY ([ServingPortionID]) REFERENCES [dbo].[ServingPortion] ([ServingPortionID])
GO
PRINT N'Adding foreign keys to [dbo].[IngredientNutrition]'
GO
ALTER TABLE [dbo].[IngredientNutrition] ADD CONSTRAINT [FK_IngredientNutrition_ServingPortionID] FOREIGN KEY ([ServingPortionID]) REFERENCES [dbo].[ServingPortion] ([ServingPortionID])
GO
PRINT N'Adding foreign keys to [dbo].[RecipeIngredient]'
GO
ALTER TABLE [dbo].[RecipeIngredient] ADD CONSTRAINT [FK_RecipeIngredient_IngredientID] FOREIGN KEY ([IngredientID]) REFERENCES [dbo].[Ingredient] ([IngredientID])
GO
ALTER TABLE [dbo].[RecipeIngredient] ADD CONSTRAINT [FK_RecipeIngredient_RecipeID] FOREIGN KEY ([RecipeID]) REFERENCES [dbo].[Recipe] ([RecipeID])
GO
