use anchor_lang::prelude::*;

declare_id!("42jc2ZN9851SM6NWMhZbowzezQrbLHP3niw12v5zVwGY");

#[program]
pub mod linkportal_contract_solana {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        msg!("Greetings from: {:?}", ctx.program_id);
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize {}
