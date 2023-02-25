pub contract FanxToken {
    pub var totalSupply: UInt64;

    pub resource interface Provider {
        pub fun withdraw(amount: UInt64): @Vault {
            post {
                result.balance == UInt64(amount):
                "Withdraw balance should be same as balance of withrwoan amount"
            }
        }
    }

    pub resource interface Receiver {
        pub fun deposit(from: @Vault) {
            pre {
                from.balance > 0:
                "Deposit balance must be positive"
            }
        }        
    }

    pub resource interface Balance {
        pub var balance: UInt64;
    }


    pub resource Vault: Receiver, Provider, Balance {
        pub var balance: UInt64;

        init(balance: UInt64) {
            self.balance = balance;
        }

        pub fun withdraw(amount: UInt64): @Vault {
            self.balance = self.balance - amount;
            return <-create Vault(balance: amount);
        }

        pub fun deposit(from: @Vault) {
            self.balance = self.balance + from.balance;
            destroy  from; 
        }
    }

    pub fun createEmptyVault(): @Vault {
        return <-create Vault(balance: 0)
    }

    pub fun createNonEmptyVault(balance: UInt64): @Vault {
        self.totalSupply = self.totalSupply +  balance;
        return <-create Vault(balance: balance);
    }

    init() {
        self.totalSupply = 1000000;
        let vault <-create Vault(balance: self.totalSupply);
        self.account.save(<-vault, to:/storage/FanxTokenVault)
    }
}
 